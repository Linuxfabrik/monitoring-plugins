Emulating `ss -antp`.

 
Known Issues:
* Does not warn on anything, because we do not know on what. Until there is some clarification, this is for debugging purposes.



CLOSED        	Closed. The socket is not being used.
CLOSING       	Closed, then remote shutdown; awaiting acknowledgment.
CLOSE_WAIT    	Remote shutdown; waiting for the socket to close - means the other end of the connection has been closed while the local end is still waiting for the application to close.
ESTABLISHED   	Connection has been established.
FIN_WAIT_1    	Socket closed; shutting down connection.
FIN_WAIT_2    	Socket closed; waiting for shutdown from remote.
IDLE          	Idle, opened but not bound.
LAST_ACK      	Remote shutdown, then closed; awaiting acknowledgment.
LISTEN        	Listening for incoming connections.
SYN_RECEIVED  	Active/initiate synchronization received and the connection under way
SYN_SENT      	Actively trying to establish connection.
TIME_WAIT     	Wait after close for remote shutdown retransmission.



Credits
* https://github.com/giampaolo/psutil/blob/master/scripts/netstat.py