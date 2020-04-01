//
//  InstructionParser.h
//  AUXACNetwork
//
//  Created by 陈凯 on 12/09/2018.
//  Copyright © 2018 陈凯. All rights reserved.
//

#ifndef InstructionParser_h
#define InstructionParser_h

#include <stdio.h>

typedef struct uart_instruction_base {
    uint16_t header;
    uint16_t cmd;
    uint16_t ret_cmd;
    uint16_t bc;
    uint8_t src;
    uint8_t dst;
}__attribute__((packed)) uart_instruction_base;

typedef struct uart_instruction_control {
    // A: 设定温度(00000~11111) + 上下摆风模式(000摆风 111固定)
    uint8_t up_down_swing : 3;
    uint8_t temperature : 5;
    
    // B: 左右摆风模式(000摆风 111固定) + 现在时间(00000~10111, hour)
    uint8_t now_hour : 5;
    uint8_t left_right_swing : 3;
    
    // C: 0.5°C的设置 + 手动发送随身感码/自动发送随身感码 + 现在时间(000000~111011, minute)
    uint8_t now_minute : 6;
    uint8_t auto_following_code : 1;
    uint8_t half : 1;
    
    // D: 风速 + 定时时间(00000~10111, hour)
    uint8_t timer_hour : 5;
    uint8_t wind_speed_1 : 3;
    
    // E: 强力&静音(00无 01强力 10静音) + 定时时间(000000~111011, minute)
    uint8_t timer_minute : 6;
    uint8_t turbo : 1;
    uint8_t silence : 1;
    
    // F: 功能(000自动 001制冷 010除湿 011保留位 100制热 101保留位 110送风 111保留位) + 清新开启/清新关闭 + 随身感功能开启/随身感功能关闭 + 睡眠开启/睡眠关闭 + 华氏温标/摄氏温标 + 人感功能开启/人感功能关闭
    uint8_t human_detection : 1;
    uint8_t fahrenheit : 1;
    uint8_t sleep_mode : 1;
    uint8_t auto_following : 1;
    uint8_t freshing : 1;
    uint8_t air_con_func : 3;
    
    // G: 保留(2bit) + 室内温度(000000~111111)
    uint8_t room_temperature : 6;
    uint8_t o_1 : 2;
    
    // H: 保留(2bit) + 室内湿度(000000~111111)
    uint8_t humidity : 6;
    uint8_t o_2 : 2;
    
    // I: 定时状态(00无 01关 10开) + 开机/关机 + 辅助电加热打开/辅助电加热关闭 + ECO打开/ECO关闭 + 清洁打开/清洁关闭 + 健康打开/健康关闭 + 空气清新打开/空气清新关闭
    uint8_t air_freshing : 1;
    uint8_t healthy : 1;
    uint8_t clean : 1;
    uint8_t eco : 1;
    uint8_t electric_heating : 1;
    uint8_t on_off : 1;
    uint8_t ac_timer : 2;
    
    // J: 保留(1bit) + 风速(0000000~1100100)
    uint8_t o_3 : 1;
    uint8_t wind_speed_2 : 7;
    
    // K: 舒适风打开/舒适风关闭 + 自动屏显打开/自动屏显关闭 + 电子锁打开/电子锁关闭 + 屏显打开/屏显关闭 + 防霉功能开启/防霉功能关闭 + 自定义睡眠开启/自定义睡眠关闭 + 控制方式(00 01 10 11)
    uint8_t control_mode : 2;
    uint8_t sleep_diy : 1;
    uint8_t anti_fungus : 1;
    uint8_t screen_on_off : 1;
    uint8_t electric_lock : 1;
    uint8_t auto_screen : 1;
    uint8_t comfort_wind : 1;
    
    // L: 限制用电开启/限制用电关闭 + 整机功率负荷百分比(000000~1100100)
    uint8_t power_limit_percent : 7;
    uint8_t power_limit : 1;
    
    // M: 保留(4bit) + 温度小数位(0000~1001)
    uint8_t temperature_decimal : 4;
    uint8_t o_4 : 4;
}__attribute__((packed)) uart_instruction_control;

typedef struct uart_instruction_status {
    // A: (家用机+单元机: 热泵机型/单冷机型 + 挂机/柜机 + 变频/定速 + 儿童空调/普通 + 除尘提醒/无 + 10分钟上报/APP查询 + 模块保护故障F1/非模块保护故障F1 + 保留位)/(多联机: 保留(4bit) + 机型(0001天花机 0010风管机 0011座吊机 0100壁挂机))
    uint8_t status_a;
    
    // B: 功能(000自动 001制冷 010除湿 011保留位 100制热 101保留位 110送风 111保留位) + 左摆风开/左摆风关 + 右摆风开/右摆风关 + 上下摆风开/上下摆风关 + 睡眠/无 + 开机/停机
    uint8_t on_off : 1;
    uint8_t sleep_mode : 1;
    uint8_t up_down_swing : 1;
    uint8_t left_right_swing : 2;
    uint8_t air_con_func : 3;
    
    // C: 清洁/无 + 防霉/无 + 除霜/无 + 回油/无 + 室外强制开停内风机/无 + 交流抽头风机/无 + 空气质量检测(00优良 01一般 10差 11保留位)
    uint8_t air_quality : 2;
    uint8_t ac_fan : 1;
    uint8_t inner_fan : 1;
    uint8_t oil_return : 1;
    uint8_t defrost : 1;
    uint8_t anti_fungus : 1;
    uint8_t clean : 1;
    
    // D: 室内风机转速(00停风 01静音风 02低风 03中低风 04中风 05中高风 06高风 07强力风)
    uint8_t inner_fan_speed;
    
    // E: 交流 PG 风机和直流风机
    uint8_t ac_pg_fan;
    
    // F: 室内环境温度
    uint8_t room_temperature;
    
    // G: 室内盘管进口温度
    uint8_t inner_coiler_in_temperature;
    
    // H: 室内盘管中部温度
    uint8_t inner_coiler_mid_temperature;
    
    // I: 室内盘管出口温度
    uint8_t inner_coiler_out_temperature;
    
    // J: 室内机膨胀阀开度
    uint8_t inner_expansion_valve_angle;
    
    // F: 室外环境温度
    uint8_t outer_temperature;
    
    // G: 室外盘管温度
    uint8_t outer_coiler_temperature;
    
    // M: 室外排气温度
    uint8_t outer_outlet_temperature;
    
    // N: 室外回气温度
    uint8_t outer_inlet_temperature;
    
    // O: 压缩机频率
    uint8_t compressor_rating;
    
    // P: 压缩机运行电流
    uint8_t compressor_current;
    
    // Q: 电源母线电压
    uint8_t compressor_voltage;
    
    // R: 室外膨胀阀开度
    uint8_t outer_expansion_valve_angle;
    
    // S: 运行功率
    uint8_t service_rating;
    
    // T: 故障
    uint8_t fault;
    
    // U: 10 分钟用电
    uint8_t energy_consumption;
    
    // V: 室内环境温度小数
    uint8_t room_temperature_decimal : 4;
    uint8_t o_1 : 4;
    
    // W: 额定功率
    uint8_t power_rating;
}__attribute__((packed)) uart_instruction_status;

typedef struct uart_instruction_diy_pointer {
    uint8_t temperature : 5;
    uint8_t wind_speed : 3;
}__attribute__((packed)) uart_instruction_diy_pointer;

typedef struct uart_instruction_alias {
    uint8_t index;
    char alias[43];
    struct uart_instruction_alias *next;
}__attribute__((packed)) uart_instruction_alias;

uint16_t uart_instruction_check_sum(uint8_t *data, uint16_t len);

struct uart_instruction_control *parse_to_control(uint8_t *buffer);

struct uart_instruction_status *parse_to_status(uint8_t *buffer, uint8_t *length);

void parse_to_diy_pointers(struct uart_instruction_diy_pointer **pointers, uint8_t *pointer_cnt, uint8_t *buffer);

void parse_to_sub_ac_dst(uint8_t *buffer, uint8_t *dst);

struct uart_instruction_alias *parse_to_aliases(uint8_t *buffer, uint8_t length);

// ----------------------------------------------------------------------------------------------------

typedef struct mtk_uart_timer_t {
    uint8_t index;
    uint8_t enable;
    uint16_t year;
    uint8_t minute;
    uint8_t second;
    uint8_t hour;
    uint8_t day;
    uint8_t month;
    uint32_t dsc[2];
}__attribute__((packed)) mtk_uart_timer_t;

typedef struct mtk_uart_cycle_t {
    uint8_t index;
    uint8_t enable;
    uint8_t week;
    uint8_t hour;
    uint8_t minute;
    uint8_t second;
    uint32_t dsc[2];
}__attribute__((packed)) mtk_uart_cycle_t;

typedef struct mtk_uart_timer_list_t {
    uint16_t count;
    mtk_uart_timer_t timer[16];
}__attribute__((packed)) mtk_uart_timer_list_t;

typedef struct mtk_uart_cycle_list_t {
    uint16_t count;
    mtk_uart_cycle_t cycle[16];
}__attribute__((packed)) mtk_uart_cycle_list_t;

typedef struct mtk_task_list_t {
    uint16_t head;
    mtk_uart_timer_list_t time_task;
    mtk_uart_timer_list_t delay_task;
    mtk_uart_cycle_list_t cycle_task;
}__attribute__((packed)) mtk_task_list_t;

typedef struct mtk_uart_cycle_task_t {
    uint16_t cmd_type;
    uint8_t timer_ype;
    uint8_t index;
    uint8_t enable;
    uint8_t week;
    uint8_t hour;
    uint8_t minute;
    uint8_t second;
    uint32_t dsc[2];
    uint8_t payload_length;
    uint8_t payload[200];
}__attribute__((packed)) uart_cycle_task_t;

// ----------------------------------------------------------------------------------------------------
// marvel
typedef struct marvel_uart_timer_t {
    uint8_t index;
    uint8_t enable;
    uint16_t year;
    uint8_t minute;
    uint8_t second;
    uint8_t hour;
    uint8_t day;
    uint8_t month;
    uint32_t dsc[3];
}__attribute__((packed)) marvel_uart_timer_t;

typedef struct marvel_uart_timer_set_t {
    marvel_uart_timer_t timer;
    uint8_t valid_len;
    char buf[200];
}__attribute__((packed)) marvel_uart_timer_set_t;

typedef struct marvel_uart_timer_list_t {
    uint16_t count;
    marvel_uart_timer_t timer[16];
    
}__attribute__((packed)) marvel_uart_timer_list_t;

typedef struct marvel_uart_cycle_t {
    uint8_t index;
    uint8_t enable;
    uint8_t week;
    uint8_t hour;
    uint8_t minute;
    uint8_t second;
    uint32_t dsc[3];
}__attribute__((packed)) marvel_uart_cycle_t;

typedef struct marvel_uart_cycle_list_t {
    uint16_t count;
    marvel_uart_cycle_t cycle[16];
}__attribute__((packed)) marvel_uart_cycle_list_t;

typedef struct marvel_task_list_t {
    uint16_t head;
    marvel_uart_timer_list_t time_task;
    marvel_uart_timer_list_t delay_task;
    marvel_uart_cycle_list_t cycle_task;
}__attribute__((packed)) marvel_task_list_t;

typedef struct marvel_uart_cycle_task_t {
    uint16_t cmd_type;
    uint8_t timer_ype;
    uint8_t index;
    uint8_t enable;
    uint8_t week;
    uint8_t hour;
    uint8_t minute;
    uint8_t second;
    uint32_t dsc[3];
    uint8_t payload_length;
    uint8_t payload[200];
}__attribute__((packed)) marvel_uart_cycle_task_t;

#endif /* InstructionParser_h */
