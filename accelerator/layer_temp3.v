module layer_temp3 (
		input clk, rst
	);

	if (pixelcount >= 9) begin  // ( width+2 for the padding )
								
		if (pixelcount == 73) begin  // (height*width + (width+1) for padding)
			pixelcount   <= 0;
			for (l=0; l<32; l=l+1) cv_rst[l] <= 1;
			
			if (inlayercount == 32) begin
				state <= STAGE6_TRANSCONV;
				inlayercount <= 0;
			end else begin
				inlayercount <= inlayercount + 32'd32;
			end
			
		end else if (layercount == 127) begin
			layercount <= 0;
			pixelcount <= pixelcount + 1;
			if (pixelcount == 72) for (l=0; l<32; l=l+1) cv_rst[l] <= 0;	 // Reset
		end else begin
			layercount <= layercount + 32'd1;	
		end
			
		// Loading weights
		if (inlayercount == 0) 
			load_weight(layercount + 85);
		else
			load_weight(layercount + 213);

		// Convolution
		for (i=0; i<32; i=i+1)	intermediate[i] <= cv_pixelout[i];
		
		// add bias and quantization
		qt0_in   <= intermediate[0] + intermediate[1] + intermediate[2] + intermediate[3]
						+ intermediate[4] + intermediate[5] + intermediate[6] + intermediate[7]
						+ intermediate[8] + intermediate[9] + intermediate[10] + intermediate[11]
						+ intermediate[12] + intermediate[13] + intermediate[14] + intermediate[15]
						+ intermediate[16] + intermediate[17] + intermediate[18] + intermediate[19]
						+ intermediate[20] + intermediate[21] + intermediate[22] + intermediate[23]
						+ intermediate[24] + intermediate[25] + intermediate[26] + intermediate[27]
						+ intermediate[28] + intermediate[29] + intermediate[30] + intermediate[31];
		qt0_zp   <= zp0;
		qt0_scale <= scale0;
			
		// save to buffer
		//                       0-word[31:24]  0-word[23:16]  0-word[15:8]  0-word[7:0]
		// ------------------------------------------------------------------------------- Q1 [63:0]
		//   layerint_buf0         L1-P1          L2-P1          L3-P1         L4-P1
		//   layerint_buf1         L5-P1          L6-P1          L7-P1         L8-P1
		//   layerint_buf2         L9-P1          L10-P1         L11-P1        L12-P1
		//   layerint_buf3         L13-P1         L14-P1         L15-P1        L16-P1
		//   layerint_buf4         L17-P1         L18-P1         L19-P1        L20-P1
		//   layerint_buf5         L21-P1         L22-P1         L23-P1        L24-P1
		//   layerint_buf6         L25-P1         L26-P1         L27-P1        L28-P1
		//   layerint_buf7         L29-P1         L30-P1         L31-P1        L32-P1
		//   layerint_buf8         L33-P1         L34-P1         L35-P1        L36-P1
		//   layerint_buf9         L37-P1         L38-P1         L39-P1        L40-P1
		//   layerint_buf10        L41-P1         L42-P1         L43-P1        L44-P1
		//   layerint_buf11        L45-P1         L46-P1         L47-P1        L48-P1
		//   layerint_buf12        L49-P1         L50-P1         L51-P1        L52-P1
		//   layerint_buf13        L53-P1         L54-P1         L55-P1        L56-P1
		//   layerint_buf14        L57-P1         L58-P1         L59-P1        L60-P1
		//   layerint_buf15        L61-P1         L62-P1         L63-P1        L64-P1
		//   layerint_buf16        L65-P1         L66-P1         L67-P1        L68-P1
		//   layerint_buf17        L69-P1         L70-P1         L71-P1        L72-P1
		//   layerint_buf18        L73-P1         L74-P1         L75-P1        L76-P1
		//   layerint_buf19        L77-P1         L78-P1         L79-P1        L80-P1
		//   layerint_buf20        L81-P1         L82-P1         L83-P1        L84-P1
		//   layerint_buf21        L85-P1         L86-P1         L87-P1        L88-P1
		//   layerint_buf22        L89-P1         L90-P1         L91-P1        L92-P1
		//   layerint_buf23        L93-P1         L94-P1         L95-P1        L96-P1
		//   layerint_buf24        L97-P1         L98-P1         L99-P1        L100-P1
		//   layerint_buf25        L101-P1        L102-P1        L103-P1       L104-P1
		//   layerint_buf26        L105-P1        L106-P1        L107-P1       L108-P1
		//   layerint_buf27        L109-P1        L110-P1        L111-P1       L112-P1
		//   layerint_buf28        L113-P1        L114-P1        L115-P1       L116-P1
		//   layerint_buf29        L117-P1        L118-P1        L119-P1       L120-P1
		//   layerint_buf30        L121-P1        L122-P1        L123-P1       L124-P1
		//   layerint_buf31        L125-P1        L126-P1        L127-P1       L128-P1
		
		case (layercount):
			32'd1:   savebuffer[31:24] <= {qt0_res};
			32'd2:   savebuffer[23:16] <= {qt0_res};
			32'd3:   savebuffer[15:8]  <= {qt0_res};
			32'd4:   layerint_buf0_st5[(pixelcount-9)] <= {(layerint_buf0_st5[(pixelcount-9)][31:24] + savebuffer[31:24])[7:0], 
																		  (layerint_buf0_st5[(pixelcount-9)][23:16] + savebuffer[23:16])[7:0],
																		  (layerint_buf0_st5[(pixelcount-9)][15:8]  + savebuffer[15:8])[7:0], 
																		  (layerint_buf0_st5[(pixelcount-9)][7:0]   + qt0_res)[7:0]};
			32'd5:   savebuffer[31:24] <= {qt0_res};
			32'd6:   savebuffer[23:16] <= {qt0_res};
			32'd7:   savebuffer[15:8]  <= {qt0_res};
			32'd8:   layerint_buf1_st5[(pixelcount-9)] <= {(layerint_buf1_st5[(pixelcount-9)][31:24] + savebuffer[31:24])[7:0], 
																		  (layerint_buf1_st5[(pixelcount-9)][23:16] + savebuffer[23:16])[7:0],
																		  (layerint_buf1_st5[(pixelcount-9)][15:8]  + savebuffer[15:8])[7:0], 
																		  (layerint_buf1_st5[(pixelcount-9)][7:0]   + qt0_res)[7:0]};
			32'd9:   savebuffer[31:24] <= {qt0_res};
			32'd10:  savebuffer[23:16] <= {qt0_res};
			32'd11:  savebuffer[15:8]  <= {qt0_res};
			32'd12:  layerint_buf2_st5[(pixelcount-9)] <= {(layerint_buf2_st5[(pixelcount-9)][31:24] + savebuffer[31:24])[7:0], 
																		  (layerint_buf2_st5[(pixelcount-9)][23:16] + savebuffer[23:16])[7:0],
																		  (layerint_buf2_st5[(pixelcount-9)][15:8]  + savebuffer[15:8])[7:0], 
																		  (layerint_buf2_st5[(pixelcount-9)][7:0]   + qt0_res)[7:0]};
			32'd13:  savebuffer[31:24] <= {qt0_res};
			32'd14:  savebuffer[23:16] <= {qt0_res};
			32'd15:  savebuffer[15:8]  <= {qt0_res};
			32'd16:  layerint_buf3_st5[(pixelcount-9)] <= {(layerint_buf3_st5[(pixelcount-9)][31:24] + savebuffer[31:24])[7:0], 
																		  (layerint_buf3_st5[(pixelcount-9)][23:16] + savebuffer[23:16])[7:0],
																		  (layerint_buf3_st5[(pixelcount-9)][15:8]  + savebuffer[15:8])[7:0], 
																		  (layerint_buf3_st5[(pixelcount-9)][7:0]   + qt0_res)[7:0]};
			32'd17:  savebuffer[31:24] <= {qt0_res};
			32'd18:  savebuffer[23:16] <= {qt0_res};
			32'd19:  savebuffer[15:8]  <= {qt0_res};
			32'd20:  layerint_buf4_st5[(pixelcount-9)] <= {(layerint_buf4_st5[(pixelcount-9)][31:24] + savebuffer[31:24])[7:0], 
																		  (layerint_buf4_st5[(pixelcount-9)][23:16] + savebuffer[23:16])[7:0],
																		  (layerint_buf4_st5[(pixelcount-9)][15:8]  + savebuffer[15:8])[7:0], 
																		  (layerint_buf4_st5[(pixelcount-9)][7:0]   + qt0_res)[7:0]};
			32'd21:  savebuffer[31:24] <= {qt0_res};
			32'd22:  savebuffer[23:16] <= {qt0_res};
			32'd23:  savebuffer[15:8]  <= {qt0_res};
			32'd24:  layerint_buf5_st5[(pixelcount-9)] <= {(layerint_buf5_st5[(pixelcount-9)][31:24] + savebuffer[31:24])[7:0], 
																		  (layerint_buf5_st5[(pixelcount-9)][23:16] + savebuffer[23:16])[7:0],
																		  (layerint_buf5_st5[(pixelcount-9)][15:8]  + savebuffer[15:8])[7:0], 
																		  (layerint_buf5_st5[(pixelcount-9)][7:0]   + qt0_res)[7:0]};
			32'd25:  savebuffer[31:24] <= {qt0_res};
			32'd26:  savebuffer[23:16] <= {qt0_res};
			32'd27:  savebuffer[15:8]  <= {qt0_res};
			32'd28:  layerint_buf6_st5[(pixelcount-9)] <= {(layerint_buf6_st5[(pixelcount-9)][31:24] + savebuffer[31:24])[7:0], 
																		  (layerint_buf6_st5[(pixelcount-9)][23:16] + savebuffer[23:16])[7:0],
																		  (layerint_buf6_st5[(pixelcount-9)][15:8]  + savebuffer[15:8])[7:0], 
																		  (layerint_buf6_st5[(pixelcount-9)][7:0]   + qt0_res)[7:0]};
			32'd29:  savebuffer[31:24] <= {qt0_res};
			32'd30:  savebuffer[23:16] <= {qt0_res};
			32'd31:  savebuffer[15:8]  <= {qt0_res};
			32'd32:  layerint_buf7_st5[(pixelcount-9)] <= {(layerint_buf7_st5[(pixelcount-9)][31:24] + savebuffer[31:24])[7:0], 
																		  (layerint_buf7_st5[(pixelcount-9)][23:16] + savebuffer[23:16])[7:0],
																		  (layerint_buf7_st5[(pixelcount-9)][15:8]  + savebuffer[15:8])[7:0], 
																		  (layerint_buf7_st5[(pixelcount-9)][7:0]   + qt0_res)[7:0]};
			32'd33:  savebuffer[31:24] <= {qt0_res};
			32'd34:  savebuffer[23:16] <= {qt0_res};
			32'd35:  savebuffer[15:8]  <= {qt0_res};
			32'd36:  layerint_buf8_st5[(pixelcount-9)] <= {(layerint_buf8_st5[(pixelcount-9)][31:24] + savebuffer[31:24])[7:0], 
																		  (layerint_buf8_st5[(pixelcount-9)][23:16] + savebuffer[23:16])[7:0],
																		  (layerint_buf8_st5[(pixelcount-9)][15:8]  + savebuffer[15:8])[7:0], 
																		  (layerint_buf8_st5[(pixelcount-9)][7:0]   + qt0_res)[7:0]};
			32'd37:  savebuffer[31:24] <= {qt0_res};
			32'd38:  savebuffer[23:16] <= {qt0_res};
			32'd39:  savebuffer[15:8]  <= {qt0_res};
			32'd40:  layerint_buf9_st5[(pixelcount-9)] <= {(layerint_buf9_st5[(pixelcount-9)][31:24] + savebuffer[31:24])[7:0], 
																		  (layerint_buf9_st5[(pixelcount-9)][23:16] + savebuffer[23:16])[7:0],
																		  (layerint_buf9_st5[(pixelcount-9)][15:8]  + savebuffer[15:8])[7:0], 
																		  (layerint_buf9_st5[(pixelcount-9)][7:0]   + qt0_res)[7:0]};
			32'd41:  savebuffer[31:24] <= {qt0_res};
			32'd42:  savebuffer[23:16] <= {qt0_res};
			32'd43:  savebuffer[15:8]  <= {qt0_res};
			32'd44:  layerint_buf10_st5[(pixelcount-9)] <= {(layerint_buf10_st5[(pixelcount-9)][31:24] + savebuffer[31:24])[7:0], 
																			(layerint_buf10_st5[(pixelcount-9)][23:16] + savebuffer[23:16])[7:0],
																			(layerint_buf10_st5[(pixelcount-9)][15:8]  + savebuffer[15:8])[7:0], 
																			(layerint_buf10_st5[(pixelcount-9)][7:0]   + qt0_res)[7:0]};
			32'd45:  savebuffer[31:24] <= {qt0_res};
			32'd46:  savebuffer[23:16] <= {qt0_res};
			32'd47:  savebuffer[15:8]  <= {qt0_res};
			32'd48:  layerint_buf11_st5[(pixelcount-9)] <= {(layerint_buf11_st5[(pixelcount-9)][31:24] + savebuffer[31:24])[7:0], 
																			(layerint_buf11_st5[(pixelcount-9)][23:16] + savebuffer[23:16])[7:0],
																			(layerint_buf11_st5[(pixelcount-9)][15:8]  + savebuffer[15:8])[7:0], 
																			(layerint_buf11_st5[(pixelcount-9)][7:0]   + qt0_res)[7:0]};
			32'd49:  savebuffer[31:24] <= {qt0_res};
			32'd50:  savebuffer[23:16] <= {qt0_res};
			32'd51:  savebuffer[15:8]  <= {qt0_res};
			32'd52:  layerint_buf12_st5[(pixelcount-9)] <= {(layerint_buf12_st5[(pixelcount-9)][31:24] + savebuffer[31:24])[7:0], 
																			(layerint_buf12_st5[(pixelcount-9)][23:16] + savebuffer[23:16])[7:0],
																			(layerint_buf12_st5[(pixelcount-9)][15:8]  + savebuffer[15:8])[7:0], 
																			(layerint_buf12_st5[(pixelcount-9)][7:0]   + qt0_res)[7:0]};
			32'd53:  savebuffer[31:24] <= {qt0_res};
			32'd54:  savebuffer[23:16] <= {qt0_res};
			32'd55:  savebuffer[15:8]  <= {qt0_res};
			32'd56:  layerint_buf13_st5[(pixelcount-9)] <= {(layerint_buf13_st5[(pixelcount-9)][31:24] + savebuffer[31:24])[7:0], 
																			(layerint_buf13_st5[(pixelcount-9)][23:16] + savebuffer[23:16])[7:0],
																			(layerint_buf13_st5[(pixelcount-9)][15:8]  + savebuffer[15:8])[7:0], 
																			(layerint_buf13_st5[(pixelcount-9)][7:0]   + qt0_res)[7:0]};
			32'd57:  savebuffer[31:24] <= {qt0_res};
			32'd58:  savebuffer[23:16] <= {qt0_res};
			32'd59:  savebuffer[15:8]  <= {qt0_res};
			32'd60:  layerint_buf14_st5[(pixelcount-9)] <= {(layerint_buf14_st5[(pixelcount-9)][31:24] + savebuffer[31:24])[7:0], 
																			(layerint_buf14_st5[(pixelcount-9)][23:16] + savebuffer[23:16])[7:0],
																			(layerint_buf14_st5[(pixelcount-9)][15:8]  + savebuffer[15:8])[7:0], 
																			(layerint_buf14_st5[(pixelcount-9)][7:0]   + qt0_res)[7:0]};
			32'd61:  savebuffer[31:24] <= {qt0_res};
			32'd62:  savebuffer[23:16] <= {qt0_res};
			32'd63:  savebuffer[15:8]  <= {qt0_res};
			32'd64:  layerint_buf15_st5[(pixelcount-9)] <= {(layerint_buf15_st5[(pixelcount-9)][31:24] + savebuffer[31:24])[7:0], 
																			(layerint_buf15_st5[(pixelcount-9)][23:16] + savebuffer[23:16])[7:0],
																			(layerint_buf15_st5[(pixelcount-9)][15:8]  + savebuffer[15:8])[7:0], 
																			(layerint_buf15_st5[(pixelcount-9)][7:0]   + qt0_res)[7:0]};
			32'd65:  savebuffer[31:24] <= {qt0_res};
			32'd66:  savebuffer[23:16] <= {qt0_res};
			32'd67:  savebuffer[15:8]  <= {qt0_res};
			32'd68:  layerint_buf16_st5[(pixelcount-9)] <= {(layerint_buf16_st5[(pixelcount-9)][31:24] + savebuffer[31:24])[7:0], 
																			(layerint_buf16_st5[(pixelcount-9)][23:16] + savebuffer[23:16])[7:0],
																			(layerint_buf16_st5[(pixelcount-9)][15:8]  + savebuffer[15:8])[7:0], 
																			(layerint_buf16_st5[(pixelcount-9)][7:0]   + qt0_res)[7:0]};
			32'd69:  savebuffer[31:24] <= {qt0_res};
			32'd70:  savebuffer[23:16] <= {qt0_res};
			32'd71:  savebuffer[15:8]  <= {qt0_res};
			32'd72:  layerint_buf17_st5[(pixelcount-9)] <= {(layerint_buf17_st5[(pixelcount-9)][31:24] + savebuffer[31:24])[7:0], 
																			(layerint_buf17_st5[(pixelcount-9)][23:16] + savebuffer[23:16])[7:0],
																			(layerint_buf17_st5[(pixelcount-9)][15:8]  + savebuffer[15:8])[7:0], 
																			(layerint_buf17_st5[(pixelcount-9)][7:0]   + qt0_res)[7:0]};
			32'd73:  savebuffer[31:24] <= {qt0_res};
			32'd74:  savebuffer[23:16] <= {qt0_res};
			32'd75:  savebuffer[15:8]  <= {qt0_res};
			32'd76:  layerint_buf18_st5[(pixelcount-9)] <= {(layerint_buf18_st5[(pixelcount-9)][31:24] + savebuffer[31:24])[7:0], 
																			(layerint_buf18_st5[(pixelcount-9)][23:16] + savebuffer[23:16])[7:0],
																			(layerint_buf18_st5[(pixelcount-9)][15:8]  + savebuffer[15:8])[7:0], 
																			(layerint_buf18_st5[(pixelcount-9)][7:0]   + qt0_res)[7:0]};
			32'd77:  savebuffer[31:24] <= {qt0_res};
			32'd78:  savebuffer[23:16] <= {qt0_res};
			32'd79:  savebuffer[15:8]  <= {qt0_res};
			32'd80:  layerint_buf19_st5[(pixelcount-9)] <= {(layerint_buf19_st5[(pixelcount-9)][31:24] + savebuffer[31:24])[7:0], 
																			(layerint_buf19_st5[(pixelcount-9)][23:16] + savebuffer[23:16])[7:0],
																			(layerint_buf19_st5[(pixelcount-9)][15:8]  + savebuffer[15:8])[7:0], 
																			(layerint_buf19_st5[(pixelcount-9)][7:0]   + qt0_res)[7:0]};
			32'd81:  savebuffer[31:24] <= {qt0_res};
			32'd82:  savebuffer[23:16] <= {qt0_res};
			32'd83:  savebuffer[15:8]  <= {qt0_res};
			32'd84:  layerint_buf20_st5[(pixelcount-9)] <= {(layerint_buf20_st5[(pixelcount-9)][31:24] + savebuffer[31:24])[7:0], 
																			(layerint_buf20_st5[(pixelcount-9)][23:16] + savebuffer[23:16])[7:0],
																			(layerint_buf20_st5[(pixelcount-9)][15:8]  + savebuffer[15:8])[7:0], 
																			(layerint_buf20_st5[(pixelcount-9)][7:0]   + qt0_res)[7:0]};
			32'd85:  savebuffer[31:24] <= {qt0_res};
			32'd86:  savebuffer[23:16] <= {qt0_res};
			32'd87:  savebuffer[15:8]  <= {qt0_res};
			32'd88:  layerint_buf21_st5[(pixelcount-9)] <= {(layerint_buf21_st5[(pixelcount-9)][31:24] + savebuffer[31:24])[7:0], 
																			(layerint_buf21_st5[(pixelcount-9)][23:16] + savebuffer[23:16])[7:0],
																			(layerint_buf21_st5[(pixelcount-9)][15:8]  + savebuffer[15:8])[7:0], 
																			(layerint_buf21_st5[(pixelcount-9)][7:0]   + qt0_res)[7:0]};
			32'd89:  savebuffer[31:24] <= {qt0_res};
			32'd90:  savebuffer[23:16] <= {qt0_res};
			32'd91:  savebuffer[15:8]  <= {qt0_res};
			32'd92:  layerint_buf22_st5[(pixelcount-9)] <= {(layerint_buf22_st5[(pixelcount-9)][31:24] + savebuffer[31:24])[7:0], 
																			(layerint_buf22_st5[(pixelcount-9)][23:16] + savebuffer[23:16])[7:0],
																			(layerint_buf22_st5[(pixelcount-9)][15:8]  + savebuffer[15:8])[7:0], 
																			(layerint_buf22_st5[(pixelcount-9)][7:0]   + qt0_res)[7:0]};
			32'd93:  savebuffer[31:24] <= {qt0_res};
			32'd94:  savebuffer[23:16] <= {qt0_res};
			32'd95:  savebuffer[15:8]  <= {qt0_res};
			32'd96:  layerint_buf23_st5[(pixelcount-9)] <= {(layerint_buf23_st5[(pixelcount-9)][31:24] + savebuffer[31:24])[7:0], 
																			(layerint_buf23_st5[(pixelcount-9)][23:16] + savebuffer[23:16])[7:0],
																			(layerint_buf23_st5[(pixelcount-9)][15:8]  + savebuffer[15:8])[7:0], 
																			(layerint_buf23_st5[(pixelcount-9)][7:0]   + qt0_res)[7:0]};
			32'd97:  savebuffer[31:24] <= {qt0_res};
			32'd98:  savebuffer[23:16] <= {qt0_res};
			32'd99:  savebuffer[15:8]  <= {qt0_res};
			32'd100: layerint_buf24_st5[(pixelcount-9)] <= {(layerint_buf24_st5[(pixelcount-9)][31:24] + savebuffer[31:24])[7:0], 
																			(layerint_buf24_st5[(pixelcount-9)][23:16] + savebuffer[23:16])[7:0],
																			(layerint_buf24_st5[(pixelcount-9)][15:8]  + savebuffer[15:8])[7:0], 
																			(layerint_buf24_st5[(pixelcount-9)][7:0]   + qt0_res)[7:0]};
			32'd101: savebuffer[31:24] <= {qt0_res};
			32'd102: savebuffer[23:16] <= {qt0_res};
			32'd103: savebuffer[15:8]  <= {qt0_res};
			32'd104: layerint_buf25_st5[(pixelcount-9)] <= {(layerint_buf25_st5[(pixelcount-9)][31:24] + savebuffer[31:24])[7:0], 
																			(layerint_buf25_st5[(pixelcount-9)][23:16] + savebuffer[23:16])[7:0],
																			(layerint_buf25_st5[(pixelcount-9)][15:8]  + savebuffer[15:8])[7:0], 
																			(layerint_buf25_st5[(pixelcount-9)][7:0]   + qt0_res)[7:0]};
			32'd105: savebuffer[31:24] <= {qt0_res};
			32'd106: savebuffer[23:16] <= {qt0_res};
			32'd107: savebuffer[15:8]  <= {qt0_res};
			32'd108: layerint_buf26_st5[(pixelcount-9)] <= {(layerint_buf26_st5[(pixelcount-9)][31:24] + savebuffer[31:24])[7:0], 
																			(layerint_buf26_st5[(pixelcount-9)][23:16] + savebuffer[23:16])[7:0],
																			(layerint_buf26_st5[(pixelcount-9)][15:8]  + savebuffer[15:8])[7:0], 
																			(layerint_buf26_st5[(pixelcount-9)][7:0]   + qt0_res)[7:0]};
			32'd109: savebuffer[31:24] <= {qt0_res};
			32'd110: savebuffer[23:16] <= {qt0_res};
			32'd111: savebuffer[15:8]  <= {qt0_res};
			32'd112: layerint_buf27_st5[(pixelcount-9)] <= {(layerint_buf27_st5[(pixelcount-9)][31:24] + savebuffer[31:24])[7:0], 
																			(layerint_buf27_st5[(pixelcount-9)][23:16] + savebuffer[23:16])[7:0],
																			(layerint_buf27_st5[(pixelcount-9)][15:8]  + savebuffer[15:8])[7:0], 
																			(layerint_buf27_st5[(pixelcount-9)][7:0]   + qt0_res)[7:0]};
			32'd113: savebuffer[31:24] <= {qt0_res};
			32'd114: savebuffer[23:16] <= {qt0_res};
			32'd115: savebuffer[15:8]  <= {qt0_res};
			32'd116: layerint_buf28_st5[[(pixelcount-9)] <= {(layerint_buf28_st5[(pixelcount-9)][31:24] + savebuffer[31:24])[7:0], 
																			 (layerint_buf28_st5[(pixelcount-9)][23:16] + savebuffer[23:16])[7:0],
																			 (layerint_buf28_st5[(pixelcount-9)][15:8]  + savebuffer[15:8])[7:0], 
																			 (layerint_buf28_st5[(pixelcount-9)][7:0]   + qt0_res)[7:0]};
			32'd117: savebuffer[31:24] <= {qt0_res};
			32'd118: savebuffer[23:16] <= {qt0_res};
			32'd119: savebuffer[15:8]  <= {qt0_res};
			32'd120: layerint_buf29_st5[(pixelcount-9)] <= {(layerint_buf29_st5[(pixelcount-9)][31:24] + savebuffer[31:24])[7:0], 
																			(layerint_buf29_st5[(pixelcount-9)][23:16] + savebuffer[23:16])[7:0],
																			(layerint_buf29_st5[(pixelcount-9)][15:8]  + savebuffer[15:8])[7:0], 
																			(layerint_buf29_st5[(pixelcount-9)][7:0]   + qt0_res)[7:0]};
			32'd121: savebuffer[31:24] <= {qt0_res};
			32'd122: savebuffer[23:16] <= {qt0_res};
			32'd123: savebuffer[15:8]  <= {qt0_res};
			32'd124: layerint_buf30_st5[(pixelcount-9)] <= {(layerint_buf30_st5[(pixelcount-9)][31:24] + savebuffer[31:24])[7:0], 
																			(layerint_buf30_st5[(pixelcount-9)][23:16] + savebuffer[23:16])[7:0],
																			(layerint_buf30_st5[(pixelcount-9)][15:8]  + savebuffer[15:8])[7:0], 
																			(layerint_buf30_st5[(pixelcount-9)][7:0]   + qt0_res)[7:0]};
			32'd125: savebuffer[31:24] <= {qt0_res};
			32'd126: savebuffer[23:16] <= {qt0_res};
			32'd127: savebuffer[15:8]  <= {qt0_res};
			32'd0:   
				begin
					if (pixelcount > 9)
						layerint_buf31_st5[(pixelcount-10)] <= {(layerint_buf31_st5[(pixelcount-10)][31:24] + savebuffer[31:24])[7:0], 
																			 (layerint_buf31_st5[(pixelcount-10)][23:16] + savebuffer[23:16])[7:0],
																			 (layerint_buf31_st5[(pixelcount-10)][15:8]  + savebuffer[15:8])[7:0], 
																			 (layerint_buf31_st5[(pixelcount-10)][7:0]   + qt0_res)[7:0]};
				end
		endcase
		
	end else begin
		pixelcount <= pixelcount + 1;
	end
endmodule 