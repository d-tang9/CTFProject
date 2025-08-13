from scapy.all import IP, ICMP, send
import textwrap, base64, time

# Target IP
target_ip = "192.168.10.1"

# hint message in plane text
hint = "You are very observent, your close! Keep digging..."
message = "Wow we have a smarty pants, flag{i_eat_icmp_packets_for_dinner}"

# convert string to bytes 
message_bytes = message.encode('utf-8')
# convert bytes to base64
base64_message = base64.b64encode(message_bytes)

print(str(base64_message))

def icmp_message(message):
	# Split message into chunks (e.g., 32 bytes each)
	chunk_size = 32
	chunks = textwrap.wrap(message, chunk_size)

	# Send each chunk in an ICMP packet
	for i, chunk in enumerate(chunks):
    		packet = IP(dst=target_ip)/ICMP(seq=i)/chunk.encode()
    		send(packet)

print("sending hint")
icmp_message(hint)
time.sleep(15)
print("sending encoded message")
icmp_message(str(base64_message))

