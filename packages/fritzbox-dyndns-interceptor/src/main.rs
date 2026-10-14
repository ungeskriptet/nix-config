use axum::{
    Router,
    extract::{ConnectInfo, Query, State},
    http::StatusCode,
    routing::get,
};
use serde::Deserialize;
use std::{
    env,
    net::{IpAddr, Ipv4Addr, Ipv6Addr, SocketAddr},
    sync::Arc,
};

const BASE_URL: &str = "https://beta.servfail.network";

#[derive(Clone)]
struct AppState {
    allowed_ips: Vec<IpAddr>,
    servfail_router_token: String,
    servfail_main_token: String,
}

#[derive(Deserialize)]
struct DynDNSParams {
    ipaddr: Option<String>,
    ip6addr: Option<String>,
}

#[tokio::main]
async fn main() {
    let shared_state = Arc::new(AppState {
        allowed_ips: get_config("ALLOWED_IPS")
            .split(",")
            .map(|s| s.to_string().parse().expect("Invalid ALLOWED_IPS"))
            .collect(),
        servfail_main_token: get_config("SERVFAIL_MAIN_TOKEN"),
        servfail_router_token: get_config("SERVFAIL_ROUTER_TOKEN"),
    });

    let addr: SocketAddr = get_config("LISTEN_ADDR")
        .parse()
        .expect("Invalid LISTEN_ADDR");

    let listener = tokio::net::TcpListener::bind(addr)
        .await
        .expect("Failed to bind to address");

    eprintln!("Server started");
    for ip in &shared_state.clone().allowed_ips {
        eprintln!("Allowed IP: {}", ip.to_string())
    }

    let app = Router::new().route("/", get(root)).with_state(shared_state);

    axum::serve(
        listener,
        app.into_make_service_with_connect_info::<SocketAddr>(),
    )
    .await
    .expect("Server error");
}

fn get_config(name: &str) -> String {
    let key = format!("DYNDNS_{}", name);
    env::var(&key).unwrap_or_else(|_| panic!("Environment variable {} is not set", key))
}

async fn update_ips(state: Arc<AppState>, params: DynDNSParams) -> () {
    let mut client = None;
    let ddns_url = format!("{}/ddns", BASE_URL);
    for ip in [&params.ipaddr, &params.ip6addr].into_iter().flatten() {
        if ip != &"".to_string() {
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
    ConnectInfo(addr): ConnectInfo<SocketAddr>,
) -> Result<(StatusCode, String), (StatusCode, String)> {
    let ip = &addr.ip().to_canonical();
    if state.allowed_ips.contains(ip) {
        tokio::spawn(update_ips(state, params));
        let msg = format!("DNS update queued from {}", ip);
        eprintln!("{}", msg);
        Ok((StatusCode::OK, msg))
    } else {
        let msg = format!("Unauthorized IP: {}", ip);
        eprintln!("{}", msg);
        Ok((StatusCode::UNAUTHORIZED, msg))
    }
}
