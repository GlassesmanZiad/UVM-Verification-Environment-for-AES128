import uvm_pkg::*;
import Pack2::*;
`include"intf.sv"

module Top();

intf intf1();

AES_Encrypt Encryptor (
				.in(intf1.Message),
				.key(intf1.Key),
				.out(intf1.ciphertext)
				);


initial begin
	uvm_config_db #(virtual intf) :: set(null,"uvm_test_top","test_vif",intf1);
	run_test("Enc_Test");
end
endmodule