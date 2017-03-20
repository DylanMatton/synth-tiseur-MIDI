library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;


entity MIDI_FSM is
  port
  (
			clk: in  std_logic;
			cmpr_state:in statecmpr;--état de la comparaison
			cmpr_res:in  std_logic;--résultat de la dernière comparaison
			cmpr_req:out std_logic;--demande d'une nouvelle comparaison
			vlq_calc_state:statecalc;--état du calcul de la VLQ
			vlq_res:in std_logic_vector(31 downto 0);--résultat du calcul de la VLQ
			vlq_req:out std_logic;--demande d'un nouveau calcul d'une VLQ
			midi_rom_Address : out std_logic_vector(32 downto 0);
			sound_rom_Address : out std_logic_vector(6 downto 0);
  )

end MIDI_FSM;
-- Machine à états contrôlant le filtre numérique.



architecture A of MID_FSM is

type READ_STATE is (CMD,EOF);
type CMDS is 
(
				NOTE_OFF,--8x
				NOTE_ON,--9x
				POLY_KEY_PRESSURE,--ax
				CONTROL_CHANGE,--bx
				PROGRAM_CHANGE,--cx
				MONO_KEY_PRESSURE,--dx
				PITCH_BEND,--ex
				SYSTEM--fx
);
type SYSTEMS is 
(
				--COMMON MESSAGES
				SYS_EXCLU,--f0
				RESERVED1,--f1
				SONG_POS_POINTER,--f2
				RESERVED2,--f4
				RESERVED3,--f5
				TUNE_REQUEST,--f6
				SYS_EXCLU_END,--f7
				--REAL TIMES MESSAGES, not used
				TIMING_CLK,--f8
				RESERVED4,--f9
				START,--fa
				CONTINUE,--fb
				STOP,--fc
				RESERVED5,--fd
				ACTIVE_SENSING,--fe
				RESET--ff	
);
type META_EV is	
(
--meta_event = 0xFF + <meta_type> + <v_length> + <event_data_bytes>
   
				SQ_NUMB,--ff00
				TXT,--ff01
				COPYRIGHT,--ff02
				TRK_NAME,--ff03
				INST_NAME,--ff04
				LYRIC,--ff05
				MARKER,--ff06
				CUE_POINT,--ff07
				PRG_NAME,--ff08
				DEVICE_NAME,--ff09
				MIDI_CHANNEL_PR,--ff2001
				MIDI_PORT,--ff2101
				END_TRACK,--ff2f00
				TEMPO,--ff5103
				SMPTE_OFFSET,--ff5405
				TIME_SIGNATURE,--ff5804
				KEY_SIGNATURE,--ff5902
				SEQ_SPECIFIC_EV,--ff7f
);
type CHUNK is 
(
				HEADER,--4d546864
				TRACK,--4d54726b		
);								
signal read_s : READ_STATE;
signal chunk_s: CHUNK;
signal cmd_s: CMDS;
signal syst_s: SYSTEMS ;
signal meta_s: META_EV;
signal delta_time_s: unsigned(31 downto 0);--32bit to store large delta times
signal count_byte: unsigned(31 downto 0);--compteur dans le fichier
signal midi_type: unsigned(1 downto 0);
signal note_lenght: unsigned(7 downto 0);
signal isnoteevent: std_logic;--

begin
Rom_Address<=std_logic_vector(s_Rom_Address);
Delay_Line_Address<=std_logic_vector(s_Delay_Line_Address);
    FSM_NEXT_STATE: process(clk, reset)
	
	begin
	if(clk'event and clk='1') then
		if(reset='1') then 
		current_state <= INIT;
		count<="00000000000000000000000000000000";--à voir
		else
		current_state<=next_state;
		count<=count_next;
		end if;
	end if;
    end process;


    P_FSM: process(read_s,chunk_s,cmd_s,syst_s,meta_s,delta_time_s)
    	
	begin			
		read_s <= READ_TIME;
		chunk_s <= TRACK;
		cmd_s <= NOTE_OFF;
		syst_s <= STOP;
		meta_s <= END_TRACK;
		delta_time_s <= "00000000000000000000000000000000";
		                

		case read_s is

			when CMD =>
				if ( chunk_s == HEADER ) then
					case count is --compteur pour savoir ou on se trouve dans le fichier
								when 10 =>  midi_type <= read_reg(0,2); --fonction de lecture
										=> note_lenght <= read_reg(2,2);
										count <= '0' --mettre le compteur a 0 pour preparer la prochaine lecture de Track
								others avancer_lecture;
										
				else 
					chunk_s <= TRACK;
					if ( count > 4 ) then
								=> delta_time_s <= read_time --apres le nombre de bytes du track chunk on lit le temps avec la fontion read_time a definir et incrementer le compteur
								=> cmd_s <= read_cmd --fonction pour lire les commandes
								case cmd_s is
									when NOTE_OFF--8x														
													=> isnoteevent <= '1';--on active le circuit de calcul de note
													--aller chercher dans la table de sinus							
									when NOTE_ON--9x
													=> isnoteevent <= '1';--on active le circuit de calcul de note
													--aller chercher dans la table de sinus
									when POLY_KEY_PRESSURE--ax
									--ignorer pour l'instant, lire 2 bytes
									when CONTROL_CHANGE--bx
									--ignorer pour l'instant, lire 2 bytes
									when PROGRAM_CHANGE--cx
									--ignorer pour l'instant, lire 1 bytes
									when MONO_KEY_PRESSURE--dx
									--ignorer pour l'instant, lire 1 bytes
									when PITCH_BEND--ex
									--ignorer pour l'instant, lire 2 bytes
									when SYSTEM--fx
										case syst_s is
											when SYS_EXCLU--f0
											--ignorer jusqu'à f7
											when RESERVED1--f1
											--ignorer lire 2 bytes
											when SONG_POS_POINTER--f2
											--ignorer 
											when RESERVED2--f4
											--ignorer 
											when RESERVED3--f5
											--ignorer 
											when TUNE_REQUEST--f6
											--ignorer 
											when SYS_EXCLU_END--f7
											--REAL TIMES MESSAGES, not used
				
											when TIMING_CLK--f8
											--ignorer 
											when RESERVED4--f9
											--ignorer 
											when START--fa
											--ignorer 
											when CONTINUE--fb
											--ignorer 
											when STOP--fc
											--ignorer 
											when RESERVED5--fd
											--ignorer 
											when ACTIVE_SENSING--fe
											--ignorer 
											when RESET--ff
												case meta_s is
													--début lire texte
													when SQ_NUMB--ff00
				
													when TXT--ff01
				
													when COPYRIGHT--ff02
				
													when TRK_NAME--ff03
			
													when INST_NAME--ff04
				
													when LYRIC--ff05
				
													when MARKER--ff06
				
													when CUE_POINT--ff07
				
													when PRG_NAME--ff08
				
													when DEVICE_NAME--ff09
				
													when MIDI_CHANNEL_PR--ff2001
				
													when MIDI_PORT--ff2101
													--fin lire texte
				
													when END_TRACK--ff2f00
													--sortir de meta_s et syst_s et cmd_s et du if, goto ?
														=> count <= "00000000000000000000000000000000"
													when TEMPO--ff5103
													--récupérer tempo et le mettre dans une 
													--variable
													when SMPTE_OFFSET--ff5405
													--ignorer ?
													when TIME_SIGNATURE--ff5804
													--ignorer pour l'instant ?
													when KEY_SIGNATURE--ff5902
													--ignorer pour l'instant ?
													when SEQ_SPECIFIC_EV--ff7f
													--lire texte ?
												end case;--meta_s
										end case;--syst_s
								end case; --cmd_s
								=> count <= "00000000000000000000000000000000"
						end if;--fin du track chunk
						
	
		when others end_of_file; --l'autre état
		end case;
	end process;
end A;
