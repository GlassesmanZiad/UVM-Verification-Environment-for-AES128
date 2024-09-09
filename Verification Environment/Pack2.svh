package Pack2;

	/* UVM package Importation and Macros */
	import uvm_pkg::*;
  	`include "uvm_macros.svh"

/************** Sequence Item Class **************/
class Enc_Sequence_Item extends uvm_sequence_item;
  	`uvm_object_utils( Enc_Sequence_Item)
	parameter Message_width = 128;
	
	rand bit [Message_width - 1 : 0] Message;
	rand bit [Message_width - 1 : 0] Key;
		 bit [Message_width - 1 : 0] ciphertext;
	function void Disp (string str ="");
		 	$display("---------------------------------------------------------------------------------------------------");
			$display("T=[%0t] [%s] Message = %h , Key = %h" , $time , str,Message,Key);
			$display("---------------------------------------------------------------------------------------------------");
	endfunction
  	function new (string name = "Enc_Sequence_Item");
		super.new(name);
	endfunction
endclass

/************** Sequence Class **************/
class Enc_Sequence extends uvm_sequence ;
	`uvm_object_utils(Enc_Sequence)
	Enc_Sequence_Item seq_item;
	int file;
	function new (string name = "Enc_Sequence");
		super.new(name);
	endfunction
	virtual task pre_body();
		seq_item = Enc_Sequence_Item ::type_id::create("seq_item");
	endtask : pre_body
	virtual task body();
		repeat(16) begin
			start_item(seq_item);
			void'(seq_item.randomize());
			finish_item(seq_item);
		end
	endtask : body
endclass

/************** Driver Class **************/
class Enc_Driver  extends uvm_driver #(Enc_Sequence_Item) ;
	`uvm_component_utils( Enc_Driver)
	virtual interface intf driver_vif;
	Enc_Sequence_Item seq_item;
	uvm_event Script_run;
	int file;
	function new (string name = "Enc_Driver", uvm_component parent = null);
		super.new(name, parent);
	endfunction

	function void build_phase(uvm_phase phase ) ; 
 		super.build_phase(phase) ;
 		seq_item  = Enc_Sequence_Item ::type_id::create("seq_item");
 		if (!uvm_config_db #(virtual intf) :: get(this,"","driver_vif" , driver_vif))
  			`uvm_fatal(get_full_name(),"Error!")
  			Script_run = new("Script_run"); 
 	endfunction
 	
 	function void connect_phase(uvm_phase phase ) ; 
 		super.connect_phase(phase) ;
 	endfunction
 	
 	task run_phase(uvm_phase phase ) ; 
 		super.run_phase(phase);
 		$display("Hi Im driver sneding data and Im starting at time [%0t] ",$time);
		$display("*******************************************************");
		forever begin
			Enc_Sequence_Item seq_item;
			seq_item_port.get_next_item(seq_item);
			#200;
			file = $fopen("verilogoutput.txt", "w");
			$fdisplay(file,"Message:%h             Key:%h",seq_item.Message,seq_item.Key);
			$fclose(file);
			seq_item.Disp("Sending Message");
			driver_vif.Message          <= seq_item.Message;
			driver_vif.Key        	    <= seq_item.Key;
			#10 seq_item_port.item_done();		
		end
 	endtask
endclass

/************** Monitor Class **************/
class Enc_Monitor extends uvm_monitor;
	`uvm_component_utils( Enc_Monitor)
	virtual interface intf monitor_vif;
	Enc_Sequence_Item seq_item_mon;
	uvm_analysis_port#(Enc_Sequence_Item)  analysis_port;
	function new (string name = "Enc_Monitor", uvm_component parent = null);
		super.new(name, parent);
	endfunction


	function void build_phase(uvm_phase phase ) ; 
 		super.build_phase(phase) ;
 		if (!uvm_config_db #(virtual intf) :: get(this,"","monitor_vif" , monitor_vif))
  			`uvm_fatal(get_full_name(),"Error!")
  		seq_item_mon  = Enc_Sequence_Item ::type_id::create("seq_item_mon");
  		analysis_port = new("analysis_port",this);
 	endfunction
 	
 	function void connect_phase(uvm_phase phase ) ; 
 		super.connect_phase(phase) ;
 	endfunction
 	
 	task run_phase(uvm_phase phase ) ; 
 		super.run_phase(phase) ;
 		forever begin
 		#210;
			seq_item_mon.ciphertext  =  monitor_vif.ciphertext;
			analysis_port.write(seq_item_mon);
		end
 	endtask
endclass

/************** Sequencer Class **************/
class Enc_Sequencer  extends uvm_sequencer #(Enc_Sequence_Item) ;
  	`uvm_component_utils( Enc_Sequencer)
  	function new (string name = "Enc_Sequencer", uvm_component parent = null);
		super.new(name, parent);
	endfunction

	function void build_phase(uvm_phase phase ) ; 
 		super.build_phase(phase) ;
 	endfunction
 	
 	function void connect_phase(uvm_phase phase ) ; 
 		super.connect_phase(phase) ;
 	endfunction
 	
 	task run_phase(uvm_phase phase ) ; 
 		super.run_phase(phase) ;
 	endtask 
endclass


class Enc_Subscriber extends uvm_subscriber #(Enc_Sequence_Item);
  	`uvm_component_utils( Enc_Subscriber)
  	function new (string name = "Enc_Subscriber", uvm_component parent = null);
		super.new(name, parent);
	endfunction

	function void write ( Enc_Sequence_Item t ) ; 
 	endfunction

 	function void build_phase(uvm_phase phase ) ; 
 		super.build_phase(phase) ;
 	endfunction
 	
 	function void connect_phase(uvm_phase phase ) ; 
 		super.connect_phase(phase) ;
 	endfunction
 	
 	task run_phase(uvm_phase phase ) ; 
 		super.run_phase(phase) ; 
 	endtask
endclass


class Enc_ScoreBoard extends uvm_scoreboard ;
	`uvm_component_utils( Enc_ScoreBoard)
	Enc_Sequence_Item seq_item_SB_EXPECTED;
	Enc_Sequence_Item seq_item_SB_ACTUAL;
	int file;
	logic [127:0] out;
	uvm_analysis_imp#(Enc_Sequence_Item,Enc_ScoreBoard) analysis_export;
	function new (string name = "Enc_ScoreBoard", uvm_component parent = null);
		super.new(name, parent);
	endfunction

	function void build_phase(uvm_phase phase ) ; 
 		super.build_phase(phase) ;
 		seq_item_SB_EXPECTED  = Enc_Sequence_Item ::type_id::create("seq_item_SB_EXPECTED");
 		seq_item_SB_ACTUAL    = Enc_Sequence_Item ::type_id::create("seq_item_SB_ACTUAL");
 		analysis_export       = new("analysis_export",this);
 	endfunction
 	
 	function void connect_phase(uvm_phase phase ) ; 
 		super.connect_phase(phase) ;
 	endfunction
 	
 	task run_phase(uvm_phase phase ) ; 
 		super.run_phase(phase) ;
 	endtask
	function void write ( Enc_Sequence_Item t ) ;	
		file = $fopen("PythonOutput.txt", "r");
		$system("C:/Users/ziada/OneDrive/Desktop/VerificationCourse/EncryptorUVM/UVM_AES128/dist/main.exe");
		$fclose(file);
		file = $fopen("PythonOutput.txt", "r");
   		$fscanf(file, "%h", out);
   		$display("Refrence Model Output: 0x%h    Dut Output: 0x%h",out,t.ciphertext);
   		$fclose(file);
   		if(out == t.ciphertext) $display("Test Passed");
   		else $display("Test fail");
 	endfunction
endclass


class Enc_Agent extends uvm_agent ;
	`uvm_component_utils( Enc_Agent)
	Enc_Sequencer my_sequencer1 ;
	Enc_Driver    my_driver1  ; 
	Enc_Monitor   my_monitor1  ;
	uvm_analysis_port#(Enc_Sequence_Item) analysis_port;
	virtual interface intf agent_vif;
	function new (string name = "Enc_Agent", uvm_component parent = null);
		super.new(name, parent);
	endfunction

	function void build_phase(uvm_phase phase ) ; 
 		super.build_phase(phase) ;
 		my_sequencer1  = Enc_Sequencer :: type_id :: create ("my_sequencer1",this ) ;
  		my_driver1 	   = Enc_Driver    :: type_id :: create ("my_driver1",this ) ;
  		my_monitor1    = Enc_Monitor   :: type_id :: create ("my_monitor1",this ) ;
  		analysis_port = new("analysis_port",this);
 		if (!uvm_config_db #(virtual intf) :: get(this,"","agent_vif" , agent_vif))
  		`uvm_fatal(get_full_name(),"Error!")
  		uvm_config_db #(virtual intf) :: set(this,"my_driver1","driver_vif" , agent_vif) ;
  		uvm_config_db #(virtual intf) :: set(this,"my_monitor1","monitor_vif", agent_vif) ;  
 	endfunction
 	
 	function void connect_phase(uvm_phase phase ) ; 
 		super.connect_phase(phase) ;
 		my_driver1.seq_item_port.connect(my_sequencer1.seq_item_export);
 		my_monitor1.analysis_port.connect(analysis_port);
 	endfunction
 	                        
 	task run_phase(uvm_phase phase ) ; 
 		super.run_phase(phase) ;
 	endtask
endclass


class Enc_Env extends uvm_env ;
	`uvm_component_utils(Enc_Env)
 	Enc_Agent      my_agent1 ; 
 	Enc_ScoreBoard my_scoreboard1 ; 
 	Enc_Subscriber my_subscriber1 ;
 	virtual intf env_vif;
	function new (string name = "Enc_Env", uvm_component parent = null);
		super.new(name, parent);
	endfunction

	function void build_phase(uvm_phase phase ) ; 
 		super.build_phase(phase) ;
 		my_agent1      = Enc_Agent      :: type_id :: create ("my_agent1",this ) ;
 		my_scoreboard1 = Enc_ScoreBoard :: type_id :: create ("my_scoreboard1",this ) ;
 		my_subscriber1 = Enc_Subscriber :: type_id :: create ("my_subscriber1",this ) ;
 		if (!uvm_config_db #(virtual intf)::get(this,"","env_vif",env_vif))
  		`uvm_fatal(get_full_name(),"Error!")
  		uvm_config_db #(virtual intf) :: set(this,"my_agent1","agent_vif",env_vif) ; 
 	endfunction
 	
 	function void connect_phase(uvm_phase phase ) ; 
 		super.connect_phase(phase) ;
 		my_agent1.analysis_port.connect(my_scoreboard1.analysis_export);
 	endfunction
 	
 	task run_phase(uvm_phase phase ) ; 
 		super.run_phase(phase) ;
 	endtask
endclass


class Enc_Test extends uvm_test ;
	`uvm_component_utils(Enc_Test)
	Enc_Sequence Enc_Sequence1 ;
 	Enc_Env my_env1 ;
 	virtual intf test_vif;
	function new (string name = "Enc_Test", uvm_component parent = null);
		super.new(name, parent);
	endfunction

	function void build_phase(uvm_phase phase ) ; 
 		super.build_phase(phase) ;
 		my_env1      = Enc_Env      :: type_id :: create ("my_env1",this ) ;
  		Enc_Sequence1 = Enc_Sequence :: type_id :: create ("Enc_Sequence1" ) ; 
  		if (!uvm_config_db #(virtual intf)::get(this,"","test_vif",test_vif))
  		`uvm_fatal(get_full_name(),"Error!")
 	    uvm_config_db #(virtual intf)::set(this ,"my_env1","env_vif",test_vif) ;
 	endfunction
 	
 	function void connect_phase(uvm_phase phase ) ; 
 		super.connect_phase(phase) ;
 	endfunction
 	
 	task  run_phase(uvm_phase phase ) ; 
 		super.run_phase(phase) ;
 		phase.raise_objection(this,"Sequence Start");
 		Enc_Sequence1.start(my_env1.my_agent1.my_sequencer1);
 		phase.drop_objection(this,"Sequence Finished");	
 	endtask 
endclass

endpackage