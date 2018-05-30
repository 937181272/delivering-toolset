> dicom 连接细节确认：
	> AE 配置
		> AE Title： SKDICOMINT
		> AE port： 11112
	> StudyDescription -- ccta
	> SeriesDescription


医院ct设备连接流程
郑医大现状：设备（CT上只是存1-2天的数据）-> 后处理工作站（多个）
现在的想法是：
    GE的设备到GE的后处理工作站（现状）
    西门子的设备统一推送到飞利浦的机器上（现状是后处理直接到西门子设备上哪，谁要谁拿，改造成到推送到统一的飞利浦的后处理工作站）

GE是一个序列叫做SS-Freez
西门子是两个序列：收缩状态（心率快的话使用），舒张状态（心率慢的话使用），需要确认下是序列名字？

冠脉cta的标识是： StudyDescription：ccta

交付事宜
1. ssh端口修改： 61022
2. 防火墙配置：sudo ufw allow from 168.0.6.12
3. 医生访问时添加一条防火墙设置
4. 密码修改
5. 停止应用的步骤: scheduler -> watch -> dicom -> srv -> 容器



一次性四个病例过来之后计算时间增长一倍一起做完在15分钟左右，不过平均到每个case也就是四分钟左右，目前估计是4个cpu的原因


sudo route delete -net 168.0.0.0 168.0.6.254
sudo route add -net 168.0.0.0 168.0.6.254


VR_CPR_RATE_REPORT:
  is_send: true
  mail_list: ['philcui@shukun.net']
  storage_dir: '/tmp/vr_cpr_report'

FEEDBACK_ISSUE_REPORT:
  is_send: true
  mail_list: ['zw@shukun.net']
  storage_dir: '/tmp/issue_stat_report'


后面能把 lib_dicom_interface_config 和 medicalbrain_cta_s_config

机器重启之后容器的数据丢失的话需要重新创建容器

对于一个新机器的安装步骤


