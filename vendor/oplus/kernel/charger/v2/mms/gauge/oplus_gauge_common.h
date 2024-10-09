#ifndef __OPLUS_GAUGE_COMMON_H__
#define __OPLUS_GAUGE_COMMON_H__

#include <oplus_mms.h>
#include "oplus_sili.h"

#define GAUGE_IC_NUM_MAX 2
#define CALIB_TIME_STR_LEN 32


struct oplus_mms_gauge {
	struct device *dev;
	struct oplus_chg_ic_dev *gauge_ic;
	struct oplus_chg_ic_dev *gauge_ic_parallel[GAUGE_IC_NUM_MAX];
	struct oplus_chg_ic_dev *voocphy_ic;
	struct oplus_mms *gauge_topic;
	struct oplus_mms *gauge_topic_parallel[GAUGE_IC_NUM_MAX];
	struct oplus_mms *comm_topic;
	struct oplus_mms *wired_topic;
	struct oplus_mms *vooc_topic;
	struct oplus_mms *err_topic;
	struct oplus_mms *parallel_topic;
	struct oplus_mms *wls_topic;
	struct mms_subscribe *comm_subs;
	struct mms_subscribe *wired_subs;
	struct mms_subscribe *gauge_subs;
	struct mms_subscribe *vooc_subs;
	struct mms_subscribe *parallel_subs;
	struct mms_subscribe *wls_subs;

	struct delayed_work hal_gauge_init_work;
	struct work_struct err_handler_work;
	struct work_struct online_handler_work;
	struct work_struct offline_handler_work;
	struct work_struct resume_handler_work;
	struct work_struct update_change_work;
	struct work_struct gauge_update_work;
	struct work_struct gauge_set_curve_work;
	struct work_struct set_gauge_batt_full_work;
	struct work_struct update_super_endurance_mode_status_work;
	struct delayed_work subboard_ntc_err_work;
	struct delayed_work deep_dischg_work;
	struct delayed_work sub_deep_dischg_work;
	struct delayed_work deep_id_work;
	struct delayed_work deep_track_work;
	struct delayed_work sub_deep_track_work;
	struct delayed_work deep_ratio_work;
	struct delayed_work deep_temp_work;

	struct votable *gauge_update_votable;
	struct deep_dischg_spec deep_spec;
	struct oplus_chg_strategy *ddrc_strategy;
	struct ddrc_temp_curves ddrc_curve;

	int device_type;
	int device_type_for_vooc;
	unsigned int vooc_sid;
	unsigned int err_code;
	int check_batt_vol_count;
	bool pd_svooc;
	bool bat_volt_different;

	bool factory_test_mode;
	bool wired_online;
	bool wls_online;
	bool hmac;
	bool parallel_hamc;
	bool support_subboard_ntc;
	bool check_subboard_ntc_err;
	bool batt_full;
	int batt_temp_region;
	int child_num;
	struct oplus_virtual_gauge_child *child_list;
	int main_gauge;
	int sub_gauge;
	int ui_soc;

	bool super_endurance_mode_status;
	int super_endurance_mode_count;
	struct votable *gauge_term_voltage_votable;
	struct votable *gauge_shutdown_voltage_votable;
	unsigned char *gauge_reg_info[GAUGE_IC_NUM_MAX];
	unsigned char calib_time_str[CALIB_TIME_STR_LEN];
	struct deep_track_info deep_info;
};

#endif /* __OPLUS_GAUGE_COMMON_H__ */
