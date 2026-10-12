use axum::{
    Router,
    extract::{Query, State},
    http::StatusCode,
    routing::get,
};
use serde::Deserialize;
use std::{
    env,
    net::{IpAddr, Ipv4Addr, Ipv6Addr},
    sync::Arc,
};

const BASE_URL: &str = "https://beta.servfail.network";

#[derive(Clone)]
struct AppState {
    token: String,
    servfail_router_token: String,
    servfail_main_token: String,
}

#[derive(Deserialize)]
struct DynDNSParams {
    token: String,
    ipaddr: Option<String>,
    ip6addr: Option<String>,
}

#[tokio::main]
async fn main() {
    let shared_state = Arc::new(AppState {
        token: get_config("TOKEN"),
        servfail_main_token: get_config("SERVFAIL_MAIN_TOKEN"),
        servfail_router_token: get_config("SERVFAIL_ROUTER_TOKEN"),
    });
    let app = Router::new().route("/", get(root)).with_state(shared_state);
    let listener = tokio::net::TcpListener::bind(get_config("LISTEN_ADDR"))
        .await
        .unwrap();
    eprintln!("Server started");
    axum::serve(listener, app).await.unwrap();
}

fn get_config(name: &str) -> String {
    let key = format!("DYNDNS_{}", name);
    env::var(&key).unwrap_or_else(|_| panic!("Environment variable {} is not set", key))
}

async fn update_ips(state: Arc<AppState>, params: DynDNSParams) -> () {
    let mut client = None;
    let ddns_url = format!("{}/ddns", BASE_URL);
    for ip in [&params.ipaddr, &params.ip6addr].into_iter().flatten() {
        let client = client.get_or_insert(reqwest::Client::new());
        match client
            .get(&ddns_url)
            .query(&[("ip", ip), ("token", &state.servfail_router_token)])
            .send()
            .await
            .and_then(reqwest::Response::error_for_status)
        {
            Err(_) => eprintln!("Failed to update router domain ({})", ip),
            _ => eprintln!("Router domain updated ({})", ip),
        }
    }
    for ip_ver in [
        IpAddr::V4(Ipv4Addr::UNSPECIFIED),
        IpAddr::V6(Ipv6Addr::UNSPECIFIED),
    ] {
        let ip_str = if ip_ver.is_ipv6() { "IPv6" } else { "IPv4" };

        let Ok(client) = reqwest::Client::builder().local_address(ip_ver).build() else {
            eprintln!("Failed to update main domain ({})", ip_str);
            continue;
        };

        match client
            .get(&ddns_url)
            .query(&[("token", &state.servfail_main_token)])
            .send()
            .await
            .and_then(reqwest::Response::error_for_status)
        {
            Err(_) => eprintln!("Failed to update main domain ({})", ip_str),
            _ => eprintln!("Main domain updated ({})", ip_str),
        }
    }
}

async fn root(
    State(state): State<Arc<AppState>>,
    Query(params): Query<DynDNSParams>,
) -> Result<(StatusCode, String), (StatusCode, String)> {
    if params.token == state.token {
        tokio::spawn(update_ips(state, params));
        let msg = "DNS update queued";
        eprintln!("{}", msg);
        Ok((StatusCode::OK, msg.to_string()))
    } else {
        let msg = "Bad token";
        eprintln!("{}", msg);
        Ok((StatusCode::UNAUTHORIZED, msg.to_string()))
    }
}
