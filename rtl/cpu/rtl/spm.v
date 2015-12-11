/*
 -- ============================================================================
 -- FILE NAME	: spm.v
 -- DESCRIPTION : spm RAM模块
 -- ----------------------------------------------------------------------------
 -- Revision  Date		  Coding_by	 Comment
 -- 1.0.0	  2011/06/27  suito		 ??????? 
 -- ============================================================================
*/

/********** 通用头文件 **********/
`include "nettype.h"
`include "global_config.h"
`include "stddef.h"

/********** 模块头文件**********/
`include "spm.h"

/********** 模块 **********/
module spm (
	/********** 输入输出参数 **********/
	input wire                 clk,            // 时钟
	/********** 端口A : IF阶段 **********/
	input wire [`SpmAddrBus]   if_spm_addr,    // 地址
	input wire                 if_spm_as_,     // 地址选通
	input wire                 if_spm_rw,      // 读/写
	input wire [`WordDataBus]  if_spm_wr_data, // 写入的数据
	output wire [`WordDataBus] if_spm_rd_data, // 读取的数据
	/********** 端口B : MEM阶段 **********/
	input wire [`SpmAddrBus]   mem_spm_addr,   // 地址
	input wire                 mem_spm_as_,    // 地址选通
	input wire                 mem_spm_rw,     // 读/写
	input wire [`WordDataBus]  mem_spm_wr_data,// 写入的数据
	output wire [`WordDataBus] mem_spm_rd_data // 读取的数据
);

	/********** 内部信号 **********/
	reg						   wea;			// 端口 A 写入有效
	reg						   web;			// 端口 B 写入有效

	/********** 写入有效信号的生成 **********/
	always @(*) begin
		/* 端口A 写入有效信号的生成 */
		if ((if_spm_as_ == `ENABLE_) && (if_spm_rw == `WRITE)) begin
			wea = `MEM_ENABLE;	// 写入有效
		end else begin
			wea = `MEM_DISABLE; // 写入无效
		end
		/* 端口B 写入有效信号的生成 */
		if ((mem_spm_as_ == `ENABLE_) && (mem_spm_rw == `WRITE)) begin
			web = `MEM_ENABLE;	// 写入有效
		end else begin
			web = `MEM_DISABLE; // 写入无效
		end
	end

	/********** Xilinx FPGA Block RAM :->altera_dpram **********/
	altera_dpram x_s3e_dpram (
		/********** 端口A : IF阶段 **********/
		.clock_a  (clk),			        // 时钟
		.address_a (if_spm_addr),     		// 地址
		.data_a  (if_spm_wr_data),    		// 写入的数据（未连接）
		.wren_a   (wea),			        // 写入有效（无效）
		.q_a (if_spm_rd_data),        		// 读取的数据
		/********** 端口B : MEM 阶段 **********/
		.clock_b  (clk),			        // 时钟
		.address_b (mem_spm_addr),	  		// 地址
		.data_b  (mem_spm_wr_data),   		//　写入的数据
		.wren_b   (web),			        // 写入有效
		.q_b (mem_spm_rd_data)        		// 读取的数据
	);

endmodule
