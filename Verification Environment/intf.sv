interface intf();

	parameter Message_width = 128;

	logic [Message_width - 1 : 0] Message;
	logic [Message_width - 1 : 0] Key;
	logic [Message_width - 1 : 0] ciphertext;

endinterface
