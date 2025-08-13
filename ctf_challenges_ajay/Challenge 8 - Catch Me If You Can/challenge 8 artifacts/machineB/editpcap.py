from scapy.all import rdpcap, wrpcap, IP, UDP, TCP

def modify_pcap(input_file, output_file):
    """
    Reads packets from input_file, changes any UDP/TCP port 5553 to 53,
    recalculates checksums, and writes to output_file.
    """
    packets = rdpcap(input_file)
    modified = []

    for pkt in packets:
        if IP in pkt:
            ip = pkt[IP]

            # Handle UDP packets
            if UDP in pkt:
                udp = pkt[UDP]
                if udp.sport == 5553:
                    udp.sport = 53
                if udp.dport == 5553:
                    udp.dport = 53

                # Force recalculation of lengths and checksums
                if hasattr(ip, 'len'):
                    del ip.len
                if hasattr(ip, 'chksum'):
                    del ip.chksum
                del udp.chksum

            # Handle TCP packets
            if TCP in pkt:
                tcp = pkt[TCP]
                if tcp.sport == 5553:
                    tcp.sport = 53
                if tcp.dport == 5553:
                    tcp.dport = 53

                # Force recalculation of lengths and checksums
                if hasattr(ip, 'len'):
                    del ip.len
                if hasattr(ip, 'chksum'):
                    del ip.chksum
                del tcp.chksum

        modified.append(pkt)

    # Write modified packets back out
    wrpcap(output_file, modified)

if __name__ == "__main__":
    import argparse
    parser = argparse.ArgumentParser(description="Modify PCAP: change port 5553 to 53")
    parser.add_argument("-i", "--input", required=True, help="Input PCAP file path")
    parser.add_argument("-o", "--output", required=True, help="Output PCAP file path")
    args = parser.parse_args()

    print(f"Processing {args.input} → {args.output}...")
    modify_pcap(args.input, args.output)
    print("Done.")
