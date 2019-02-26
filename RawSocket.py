# Import modules to enable socket creation (socket), system functions
# (sys), packing (struct), and text obfuscation (base64).
import socket
import sys
import base64
from struct import *

# Set up variables that may need to be changed.
src_ip = '10.1.0.2'
dest_ip = '10.1.0.1'
port = 12345

# Set up other variables used in the construction of the IP header.
ip_ver_ihl = '0x45'    # Version and IHL (assuming no options)
ip_dscp = '0x0'        # DSCP (formerly TOS)
ip_length = '0x0'      # The kernel will overwrite this value
ip_id = '0x1'          # Arbitrary ID number
ip_flags = '0x4000'    # Don't fragment
ip_ttl = 64            # TTL of 64 matches most Linux kernels
ip_protocol = 63       # "Any host internal protocol" (IANA)
ip_checksum = '0x0'    # The kernel will overwrite this value
ip_sourceaddr = socket.inet_aton (src_ip)
ip_destaddr = socket.inet_aton (dest_ip)

# Create the socket.
try:
    s = socket.socket(socket.AF_INET, socket.SOCK_RAW, socket.IPPROTO_RAW)
except socket.error as msg:
    print ('Socket creation failed.  Error code ' + str(msg[0]) + ': ' + msg[1])
    sys.exit()

# Build the packet header as a C struct.  The format string specifies
# the byte order (big endian) and the size of each field (RFC 791).
#   B (unsigned char): 1 byte / 8 bits
#   H (unsigned short): 2 bytes / 16 bits
#   4s (char[] x4): 4 bytes / 32 bits
ip_header = pack('>BBHHHBBH4s4s',
        int(ip_ver_ihl, 0),
        int(ip_dscp, 0),
        int(ip_length, 0),
        int(ip_id, 0),
        int(ip_flags, 0),
        ip_ttl,
        ip_protocol,
        int(ip_checksum, 0),
        ip_sourceaddr,
        ip_destaddr)

# Build the packet payload.
payload = 'The quick brown fox jumped over the lazy dog.'
# Obfuscate with Base64.  Note: encode the string to UTF-8 to pass the 
# required bytes-like object to the b64encode method.
encoded_payload = base64.b64encode(payload.encode())

# Assemble the packet from the header and payload.
packet = ip_header + encoded_payload

# Transmit the packet through the socket.
s.sendto(packet, (dest_ip, port))