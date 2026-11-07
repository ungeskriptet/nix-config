from uuid import UUID
from sys import argv


def usage():
    print(f"Usage: {argv[0]} [ little | big ] <UUID>")


if len(argv) <= 2:
    usage()
    quit()

uuid = UUID(argv[2])

if argv[1] == "little":
    uuid = (
        uuid.fields[0],
        uuid.fields[1],
        uuid.fields[2],
        uuid.fields[4],
        uuid.fields[3],
        uuid.fields[5],
    )
    uuid = UUID(fields=uuid).bytes_le
elif argv[1] == "big":
    uuid = uuid.bytes
else:
    usage()
    quit(1)

print("\\x" + "\\x".join([f"{b:02x}" for b in uuid]))
