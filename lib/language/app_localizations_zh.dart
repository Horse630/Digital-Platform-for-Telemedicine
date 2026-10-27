// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => '遠距醫療數位平台';

  @override
  String get appTagline => '把遠距照護、預約和後續跟進放在同一個地方。';

  @override
  String get username => '使用者名稱';

  @override
  String get password => '密碼';

  @override
  String get email => '電郵';

  @override
  String get confirmPassword => '確認密碼';

  @override
  String get enterUsername => '請輸入使用者名稱';

  @override
  String get enterPassword => '請輸入密碼';

  @override
  String get enterUsernameAndPassword => '請輸入使用者名稱和密碼。';

  @override
  String get enterValidEmail => '請輸入有效的電郵。';

  @override
  String get usernameRule => '請使用 3 至 40 個英文字母、數字、點、底線或連字號。';

  @override
  String get atLeast8 => '請至少使用 8 個字元。';

  @override
  String get samePasswordTwice => '請輸入兩次相同的密碼。';

  @override
  String get signIn => '登入';

  @override
  String get continueAs => '直接登入';

  @override
  String get createAccount => '建立帳號';

  @override
  String get forgotPassword => '忘記密碼？';

  @override
  String get resetPasswordTitle => '重設密碼';

  @override
  String get resetPasswordHint => '輸入帳號的電郵。寄出重設電郵的功能尚未接上。';

  @override
  String get sendResetLink => '傳送重設連結';

  @override
  String get resetEmailNotSent => '重設電郵尚未寄出。';

  @override
  String get createAccountAction => '建立帳號';

  @override
  String get creating => '建立中...';

  @override
  String get showPassword => '顯示密碼';

  @override
  String get hidePassword => '隱藏密碼';

  @override
  String get patient => '病人';

  @override
  String get doctor => '醫生';

  @override
  String get admin => '管理員';

  @override
  String welcomeBack(String name) {
    return '歡迎回來，$name';
  }

  @override
  String get doctorDashboard => '醫生主頁';

  @override
  String get patientDashboard => '病人主頁';

  @override
  String get adminDashboard => '管理員主頁';

  @override
  String get navHome => '主頁';

  @override
  String get navAppointments => '預約';

  @override
  String get navMessages => '訊息';

  @override
  String get noMessages => '還沒有訊息。';

  @override
  String get noMessagesHint => '可以從預約向醫生或病人傳訊息。';

  @override
  String get messageAction => '傳訊息';

  @override
  String get send => '傳送';

  @override
  String get messageHint => '輸入訊息';

  @override
  String get messageSent => '已傳送';

  @override
  String get messageRead => '已讀';

  @override
  String get patientProfile => '病人資料';

  @override
  String get msgEnterMessage => '請輸入訊息。';

  @override
  String get msgMessageTooLong => '訊息請保持在 500 字以內。';

  @override
  String get msgCannotMessageYourself => '不能傳訊息給自己。';

  @override
  String get msgPersonNotFound => '找不到這個人。';

  @override
  String get msgMessagesUnread => '無法讀取訊息。';

  @override
  String get msgMessageFailed => '訊息要求失敗。';

  @override
  String get navConsultation => '諮詢';

  @override
  String get navProfile => '個人資料';

  @override
  String get overview => '概覽';

  @override
  String get coreServices => '主要服務';

  @override
  String get otherServices => '其他服務';

  @override
  String get nextAppointment => '下一個預約';

  @override
  String get notScheduled => '尚未安排';

  @override
  String get noActiveOrder => '沒有進行中的訂單';

  @override
  String get appointmentsSubtitle => '預約一次遠距診症';

  @override
  String get consultationTitle => '諮詢';

  @override
  String get consultationSubtitle => '與醫生對話';

  @override
  String get sickLeave => '病假紙';

  @override
  String get sickLeaveSubtitle => '只供閱讀的證明';

  @override
  String get payment => '付款';

  @override
  String get paymentSubtitle => '診症和送藥費用';

  @override
  String get medicationDelivery => '藥物配送';

  @override
  String get medicationDeliverySubtitle => '追蹤處方藥物';

  @override
  String get aiChatbot => '人工智能助手';

  @override
  String get aiChatbotSubtitle => '指引和提問';

  @override
  String get discussion => '討論';

  @override
  String get discussionSubtitle => '向醫生公開提問';

  @override
  String get askQuestion => '提出問題';

  @override
  String get questionTitle => '標題';

  @override
  String get questionBody => '你的問題';

  @override
  String get postQuestion => '發佈';

  @override
  String get noDiscussions => '還沒有問題。';

  @override
  String get noDiscussionsHint => '所有人都可以看問題。只有醫生可以回覆，多於一位醫生也可以回覆。';

  @override
  String get discussionOpen => '待回覆';

  @override
  String get discussionAnswered => '已回覆';

  @override
  String get publicReply => '公開回覆';

  @override
  String get noRepliesYet => '還沒有回覆。';

  @override
  String get replyHint => '寫下建議或簡單說明';

  @override
  String get searchPosts => '搜尋帖子';

  @override
  String get noMatchingPosts => '沒有相符的帖子。';

  @override
  String get editReply => '編輯回覆';

  @override
  String get saveReply => '儲存';

  @override
  String get confirmRemoveReplyTitle => '移除這則回覆？';

  @override
  String get confirmRemoveReplyMessage => '這則回覆會被刪除。';

  @override
  String get msgOnlyReplyAuthor => '只有寫下這則回覆的醫生可以更改。';

  @override
  String get replyAction => '回覆';

  @override
  String get allComments => '全部回覆';

  @override
  String get myComments => '我的回覆';

  @override
  String get noStoredReplies => '你還沒有收藏回覆。';

  @override
  String get likeAction => '讚好';

  @override
  String get storeAction => '收藏';

  @override
  String get storedAction => '已收藏';

  @override
  String get publicDiscussions => '公開討論';

  @override
  String get myDiscussions => '我的討論';

  @override
  String get noMyDiscussions => '你還沒有發佈討論。';

  @override
  String get myResponses => '我的回覆';

  @override
  String get noMyResponses => '你還沒有回覆討論。';

  @override
  String get confirmRemovePostTitle => '移除這則帖子？';

  @override
  String get confirmRemovePostMessage => '這則帖子和回覆會被刪除。';

  @override
  String get msgOnlyPosterCanRemove => '只有發帖的人可以移除。';

  @override
  String replyCount(int count) {
    return '$count 則回覆';
  }

  @override
  String get msgOnlyPatientCanAsk => '只有病人可以發問。';

  @override
  String get msgOnlyDoctorCanReply => '只有醫生可以回覆。';

  @override
  String get msgEnterTitle => '請輸入標題。';

  @override
  String get msgTitleTooLong => '標題請少於 120 個字。';

  @override
  String get msgEnterQuestion => '請輸入問題。';

  @override
  String get msgQuestionTooLong => '問題請少於 1000 個字。';

  @override
  String get msgEnterReply => '請輸入回覆。';

  @override
  String get msgReplyTooLong => '回覆請少於 1000 個字。';

  @override
  String get msgQuestionNotFound => '找不到這個問題。';

  @override
  String get msgDiscussionFailed => '討論請求失敗。';

  @override
  String get msgDiscussionsUnread => '無法讀取討論列表。';

  @override
  String get iotHealth => '健康裝置';

  @override
  String get iotHealthSubtitle => '穿戴裝置讀數';

  @override
  String get serviceUnavailable => '這項服務尚未開放。';

  @override
  String get close => '關閉';

  @override
  String patientLine(String name) {
    return '病人：$name';
  }

  @override
  String get unknown => '未知';

  @override
  String get noPatientYet => '尚未有病人';

  @override
  String get openForPatients => '開放給病人';

  @override
  String get noAppointment => '沒有預約';

  @override
  String get noAppointmentYet => '你還沒有預約。';

  @override
  String get noAppointmentOnDay => '這一天沒有預約。';

  @override
  String get noAppointmentsYet => '尚未有預約';

  @override
  String get doctorsHaveNotPublished => '醫生尚未公布時段。';

  @override
  String get appointmentsUnavailable => '暫時無法載入預約';

  @override
  String get makeAppointment => '建立預約時段';

  @override
  String get bookAppointment => '預約看診';

  @override
  String get bookThisTime => '預約這個時段';

  @override
  String get reasonForVisit => '看診原因';

  @override
  String get enterShortReason => '請輸入簡短的看診原因。';

  @override
  String get book => '預約';

  @override
  String get openTimes => '可預約時段';

  @override
  String get doctorName => '醫生姓名';

  @override
  String get viewDoctorProfile => '查看資料';

  @override
  String get doctorProfile => '醫生資料';

  @override
  String get noDescription => '尚未填寫簡介。';

  @override
  String get allTypes => '全部科別';

  @override
  String get doctorTypeLabel => '醫生科別';

  @override
  String get sort => '排序';

  @override
  String get soonest => '最近的時間';

  @override
  String get latest => '最遠的時間';

  @override
  String get nameAz => '姓名 A–Z';

  @override
  String get nameZa => '姓名 Z–A';

  @override
  String get noOpenTimes => '暫時沒有可預約時段。醫生尚未公布時間。';

  @override
  String get noOpenTimesMatch => '沒有符合這個搜尋的時段。';

  @override
  String get calendar => '日曆';

  @override
  String get list => '列表';

  @override
  String get previousMonth => '上個月';

  @override
  String get nextMonth => '下個月';

  @override
  String get cancelSlot => '取消時段';

  @override
  String get cancelBooking => '取消預約';

  @override
  String get confirmCancelTitle => '要取消這項預約嗎？';

  @override
  String get confirmCancelSlotMessage => '病人將不能再預約這個時段。';

  @override
  String get confirmCancelVisitMessage => '這次看診會被取消。';

  @override
  String get confirmCancelBookingMessage => '這項預約會取消，時段會重新開放。';

  @override
  String get confirmRemoveTitle => '要刪除這項預約嗎？';

  @override
  String get confirmRemoveMessage => '這筆已取消的紀錄會被刪除。';

  @override
  String get remove => '刪除';

  @override
  String get keep => '保留';

  @override
  String get msgOnlyCancelled => '只有已取消的預約可以刪除。';

  @override
  String get chooseFutureTime => '請選擇一個未來的時間。';

  @override
  String get statusAvailable => '可預約';

  @override
  String get statusScheduled => '已預約';

  @override
  String get statusCancelled => '已取消';

  @override
  String get settings => '設定';

  @override
  String get language => '語言';

  @override
  String get languageStaysOnDevice => '語言設定只保存在這台裝置。';

  @override
  String get appearance => '外觀';

  @override
  String get darkMode => '深色模式';

  @override
  String get darkModeSubtitle => '在淺色和深色之間切換';

  @override
  String get appColor => '應用程式顏色';

  @override
  String get colorStaysOnDevice => '顏色和深色模式只保存在這台裝置。';

  @override
  String get fontSize => '字體大小';

  @override
  String get fontSizeSmall => '小';

  @override
  String get fontSizeNormal => '標準';

  @override
  String get fontSizeLarge => '大';

  @override
  String get fontSizeExtra => '特大';

  @override
  String get fontSizeStaysOnDevice => '字體大小只保存在這台裝置，並套用到每一頁。';

  @override
  String get account => '帳號';

  @override
  String get passwordSection => '密碼';

  @override
  String get uploadPhoto => '上傳相片';

  @override
  String get removePhoto => '移除相片';

  @override
  String get description => '簡介';

  @override
  String get saveProfile => '儲存個人資料';

  @override
  String get saving => '儲存中...';

  @override
  String get profileSaved => '個人資料已儲存。';

  @override
  String get allergies => '過敏';

  @override
  String get addAllergyHint => '輸入一項過敏';

  @override
  String get addAllergy => '加入過敏';

  @override
  String get currentPassword => '目前密碼';

  @override
  String get newPassword => '新密碼';

  @override
  String get confirmNewPassword => '確認新密碼';

  @override
  String get changePassword => '變更密碼';

  @override
  String get updating => '更新中...';

  @override
  String get enterCurrentPassword => '請輸入目前密碼。';

  @override
  String get differentPassword => '請選擇另一個密碼。';

  @override
  String get retry => '再試一次';

  @override
  String get logOut => '登出';

  @override
  String get videoNotAvailable => '視像診症尚未開放';

  @override
  String get videoNotAvailableMessage => '你現在可以先預約時間。視像通話準備好後會在這裡開啟。';

  @override
  String get teal => '青綠色';

  @override
  String get blue => '藍色';

  @override
  String get green => '綠色';

  @override
  String get purple => '紫色';

  @override
  String get orange => '橙色';

  @override
  String get typeGeneralPractice => '全科';

  @override
  String get typeFamilyMedicine => '家庭醫學';

  @override
  String get typeInternalMedicine => '內科';

  @override
  String get typePaediatrics => '兒科';

  @override
  String get typeObstetrics => '婦產科';

  @override
  String get typeSurgery => '外科';

  @override
  String get typeOrthopaedics => '骨科';

  @override
  String get typeDermatology => '皮膚科';

  @override
  String get typePsychiatry => '精神科';

  @override
  String get typeOphthalmology => '眼科';

  @override
  String get typeOtorhinolaryngology => '耳鼻喉科';

  @override
  String get typeCardiology => '心臟科';

  @override
  String get msgUsernameOrPassword => '使用者名稱或密碼不正確。';

  @override
  String get msgCannotReach => '無法連接服務。請檢查網絡後再試。';

  @override
  String get msgUsernameUsed => '這個使用者名稱已被使用。';

  @override
  String get msgEmailUsed => '這個電郵已被使用。';

  @override
  String get msgSignInFailed => '登入失敗。請再試一次。';

  @override
  String get msgChooseRole => '請選擇病人或醫生。';

  @override
  String get msgCouldNotCreate => '無法建立帳號。';

  @override
  String get msgRequestFailed => '要求失敗。請再試一次。';

  @override
  String get msgSignInAgain => '請重新登入。';

  @override
  String get msgProfileUnread => '無法讀取個人資料。';

  @override
  String get msgAccountUnavailable => '帳號服務暫時無法使用。請稍後再試。';

  @override
  String get msgProfileFailed => '個人資料要求失敗。';

  @override
  String get msgPasswordUpdated => '密碼已更新。';

  @override
  String get msgCurrentPasswordWrong => '目前密碼不正確。';

  @override
  String get msgEnterBothPasswords => '請輸入目前密碼和新密碼。';

  @override
  String get msgDescriptionLimit => '簡介請保持在 280 字以內。';

  @override
  String get msgCouldNotSaveProfile => '無法儲存個人資料。';

  @override
  String get msgBadPhoto => '請選擇小於 512 KB 的 JPEG、PNG 或 WebP 圖片。';

  @override
  String get msgChooseDoctorTypes => '請從清單中選擇醫生科別。';

  @override
  String get msgAllergiesList => '請以清單輸入過敏。';

  @override
  String get msgAllergyCount => '過敏項目請保持在 20 項以內。';

  @override
  String get msgAllergyName => '請輸入簡短的過敏名稱。';

  @override
  String get msgAllergyLength => '每項過敏請保持在 40 字以內。';

  @override
  String get msgAppointmentUnread => '無法讀取預約清單。';

  @override
  String get msgAppointmentFailed => '預約要求失敗。';

  @override
  String get msgSlotTaken => '你在這個時間已經有時段。';

  @override
  String get msgOnlyDoctor => '只有醫生可以新增時段。';

  @override
  String get msgOnlyPatient => '只有病人可以預約時段。';

  @override
  String get msgSlotGone => '這個時段已不能預約。';

  @override
  String get msgAppointmentMissing => '找不到這項預約。';

  @override
  String get msgCannotChange => '你不能更改這項預約。';
}

/// The translations for Chinese, using the Han script (`zh_Hans`).
class AppLocalizationsZhHans extends AppLocalizationsZh {
  AppLocalizationsZhHans() : super('zh_Hans');

  @override
  String get appTitle => '远程医疗数字平台';

  @override
  String get appTagline => '把远程照护、预约和后续跟进放在同一个地方。';

  @override
  String get username => '用户名';

  @override
  String get password => '密码';

  @override
  String get email => '邮箱';

  @override
  String get confirmPassword => '确认密码';

  @override
  String get enterUsername => '请输入用户名';

  @override
  String get enterPassword => '请输入密码';

  @override
  String get enterUsernameAndPassword => '请输入用户名和密码。';

  @override
  String get enterValidEmail => '请输入有效的邮箱。';

  @override
  String get usernameRule => '请使用 3 至 40 个英文字母、数字、点、下划线或连字符。';

  @override
  String get atLeast8 => '请至少使用 8 个字符。';

  @override
  String get samePasswordTwice => '请输入两次相同的密码。';

  @override
  String get signIn => '登录';

  @override
  String get continueAs => '直接登录';

  @override
  String get createAccount => '创建账号';

  @override
  String get forgotPassword => '忘记密码？';

  @override
  String get resetPasswordTitle => '重设密码';

  @override
  String get resetPasswordHint => '输入账号的邮箱。寄出重设邮件的功能尚未接上。';

  @override
  String get sendResetLink => '发送重设链接';

  @override
  String get resetEmailNotSent => '重设邮件尚未寄出。';

  @override
  String get createAccountAction => '创建账号';

  @override
  String get creating => '创建中...';

  @override
  String get showPassword => '显示密码';

  @override
  String get hidePassword => '隐藏密码';

  @override
  String get patient => '患者';

  @override
  String get doctor => '医生';

  @override
  String get admin => '管理员';

  @override
  String welcomeBack(String name) {
    return '欢迎回来，$name';
  }

  @override
  String get doctorDashboard => '医生主页';

  @override
  String get patientDashboard => '患者主页';

  @override
  String get adminDashboard => '管理员主页';

  @override
  String get navHome => '首页';

  @override
  String get navAppointments => '预约';

  @override
  String get navMessages => '消息';

  @override
  String get noMessages => '还没有消息。';

  @override
  String get noMessagesHint => '可以从预约向医生或患者发消息。';

  @override
  String get messageAction => '发消息';

  @override
  String get send => '发送';

  @override
  String get messageHint => '输入消息';

  @override
  String get messageSent => '已发送';

  @override
  String get messageRead => '已读';

  @override
  String get patientProfile => '患者资料';

  @override
  String get msgEnterMessage => '请输入消息。';

  @override
  String get msgMessageTooLong => '消息请保持在 500 字以内。';

  @override
  String get msgCannotMessageYourself => '不能给自己发消息。';

  @override
  String get msgPersonNotFound => '找不到这个人。';

  @override
  String get msgMessagesUnread => '无法读取消息。';

  @override
  String get msgMessageFailed => '消息请求失败。';

  @override
  String get navConsultation => '咨询';

  @override
  String get navProfile => '个人资料';

  @override
  String get overview => '概览';

  @override
  String get coreServices => '主要服务';

  @override
  String get otherServices => '其他服务';

  @override
  String get nextAppointment => '下一次预约';

  @override
  String get notScheduled => '尚未安排';

  @override
  String get noActiveOrder => '没有进行中的订单';

  @override
  String get appointmentsSubtitle => '预约一次远程问诊';

  @override
  String get consultationTitle => '咨询';

  @override
  String get consultationSubtitle => '与医生对话';

  @override
  String get sickLeave => '病假单';

  @override
  String get sickLeaveSubtitle => '只供阅读的证明';

  @override
  String get payment => '付款';

  @override
  String get paymentSubtitle => '问诊和送药费用';

  @override
  String get medicationDelivery => '药物配送';

  @override
  String get medicationDeliverySubtitle => '追踪处方药物';

  @override
  String get aiChatbot => '人工智能助手';

  @override
  String get aiChatbotSubtitle => '指引和提问';

  @override
  String get discussion => '讨论';

  @override
  String get discussionSubtitle => '向医生公开提问';

  @override
  String get askQuestion => '提出问题';

  @override
  String get questionTitle => '标题';

  @override
  String get questionBody => '你的问题';

  @override
  String get postQuestion => '发布';

  @override
  String get noDiscussions => '还没有问题。';

  @override
  String get noDiscussionsHint => '所有人都可以看问题。只有医生可以回复，多于一位医生也可以回复。';

  @override
  String get discussionOpen => '待回复';

  @override
  String get discussionAnswered => '已回复';

  @override
  String get publicReply => '公开回复';

  @override
  String get noRepliesYet => '还没有回复。';

  @override
  String get replyHint => '写下建议或简单说明';

  @override
  String get searchPosts => '搜索帖子';

  @override
  String get noMatchingPosts => '没有相符的帖子。';

  @override
  String get editReply => '编辑回复';

  @override
  String get saveReply => '保存';

  @override
  String get confirmRemoveReplyTitle => '移除这条回复？';

  @override
  String get confirmRemoveReplyMessage => '这条回复会被删除。';

  @override
  String get msgOnlyReplyAuthor => '只有写下这条回复的医生可以更改。';

  @override
  String get replyAction => '回复';

  @override
  String get allComments => '全部回复';

  @override
  String get myComments => '我的回复';

  @override
  String get noStoredReplies => '你还没有收藏回复。';

  @override
  String get likeAction => '赞';

  @override
  String get storeAction => '收藏';

  @override
  String get storedAction => '已收藏';

  @override
  String get publicDiscussions => '公开讨论';

  @override
  String get myDiscussions => '我的讨论';

  @override
  String get noMyDiscussions => '你还没有发布讨论。';

  @override
  String get myResponses => '我的回复';

  @override
  String get noMyResponses => '你还没有回复讨论。';

  @override
  String get confirmRemovePostTitle => '移除这则帖子？';

  @override
  String get confirmRemovePostMessage => '这则帖子和回复会被删除。';

  @override
  String get msgOnlyPosterCanRemove => '只有发帖的人可以移除。';

  @override
  String replyCount(int count) {
    return '$count 条回复';
  }

  @override
  String get msgOnlyPatientCanAsk => '只有患者可以提问。';

  @override
  String get msgOnlyDoctorCanReply => '只有医生可以回复。';

  @override
  String get msgEnterTitle => '请输入标题。';

  @override
  String get msgTitleTooLong => '标题请少于 120 个字。';

  @override
  String get msgEnterQuestion => '请输入问题。';

  @override
  String get msgQuestionTooLong => '问题请少于 1000 个字。';

  @override
  String get msgEnterReply => '请输入回复。';

  @override
  String get msgReplyTooLong => '回复请少于 1000 个字。';

  @override
  String get msgQuestionNotFound => '找不到这个问题。';

  @override
  String get msgDiscussionFailed => '讨论请求失败。';

  @override
  String get msgDiscussionsUnread => '无法读取讨论列表。';

  @override
  String get iotHealth => '健康设备';

  @override
  String get iotHealthSubtitle => '穿戴设备读数';

  @override
  String get serviceUnavailable => '这项服务尚未开放。';

  @override
  String get close => '关闭';

  @override
  String patientLine(String name) {
    return '患者：$name';
  }

  @override
  String get unknown => '未知';

  @override
  String get noPatientYet => '还没有患者';

  @override
  String get openForPatients => '开放给患者';

  @override
  String get noAppointment => '没有预约';

  @override
  String get noAppointmentYet => '你还没有预约。';

  @override
  String get noAppointmentOnDay => '这一天没有预约。';

  @override
  String get noAppointmentsYet => '还没有预约';

  @override
  String get doctorsHaveNotPublished => '医生尚未公布时段。';

  @override
  String get appointmentsUnavailable => '暂时无法加载预约';

  @override
  String get makeAppointment => '创建预约时段';

  @override
  String get bookAppointment => '预约就诊';

  @override
  String get bookThisTime => '预约这个时段';

  @override
  String get reasonForVisit => '就诊原因';

  @override
  String get enterShortReason => '请输入简短的就诊原因。';

  @override
  String get book => '预约';

  @override
  String get openTimes => '可预约时段';

  @override
  String get doctorName => '医生姓名';

  @override
  String get viewDoctorProfile => '查看资料';

  @override
  String get doctorProfile => '医生资料';

  @override
  String get noDescription => '尚未填写简介。';

  @override
  String get allTypes => '全部科室';

  @override
  String get doctorTypeLabel => '医生科室';

  @override
  String get sort => '排序';

  @override
  String get soonest => '最近的时间';

  @override
  String get latest => '最远的时间';

  @override
  String get nameAz => '姓名 A–Z';

  @override
  String get nameZa => '姓名 Z–A';

  @override
  String get noOpenTimes => '暂时没有可预约时段。医生尚未公布时间。';

  @override
  String get noOpenTimesMatch => '没有符合这个搜索的时段。';

  @override
  String get calendar => '日历';

  @override
  String get list => '列表';

  @override
  String get previousMonth => '上个月';

  @override
  String get nextMonth => '下个月';

  @override
  String get cancelSlot => '取消时段';

  @override
  String get cancelBooking => '取消预约';

  @override
  String get confirmCancelTitle => '要取消这项预约吗？';

  @override
  String get confirmCancelSlotMessage => '患者将不能再预约这个时段。';

  @override
  String get confirmCancelVisitMessage => '这次问诊会被取消。';

  @override
  String get confirmCancelBookingMessage => '这项预约会取消，时段会重新开放。';

  @override
  String get confirmRemoveTitle => '要删除这项预约吗？';

  @override
  String get confirmRemoveMessage => '这笔已取消的记录会被删除。';

  @override
  String get remove => '删除';

  @override
  String get keep => '保留';

  @override
  String get msgOnlyCancelled => '只有已取消的预约可以删除。';

  @override
  String get chooseFutureTime => '请选择一个未来的时间。';

  @override
  String get statusAvailable => '可预约';

  @override
  String get statusScheduled => '已预约';

  @override
  String get statusCancelled => '已取消';

  @override
  String get settings => '设置';

  @override
  String get language => '语言';

  @override
  String get languageStaysOnDevice => '语言设置只保存在这台设备。';

  @override
  String get appearance => '外观';

  @override
  String get darkMode => '深色模式';

  @override
  String get darkModeSubtitle => '在浅色和深色之间切换';

  @override
  String get appColor => '应用颜色';

  @override
  String get colorStaysOnDevice => '颜色和深色模式只保存在这台设备。';

  @override
  String get fontSize => '字体大小';

  @override
  String get fontSizeSmall => '小';

  @override
  String get fontSizeNormal => '标准';

  @override
  String get fontSizeLarge => '大';

  @override
  String get fontSizeExtra => '特大';

  @override
  String get fontSizeStaysOnDevice => '字体大小只保存在这台设备，并应用到每一页。';

  @override
  String get account => '账号';

  @override
  String get passwordSection => '密码';

  @override
  String get uploadPhoto => '上传照片';

  @override
  String get removePhoto => '移除照片';

  @override
  String get description => '简介';

  @override
  String get saveProfile => '保存个人资料';

  @override
  String get saving => '保存中...';

  @override
  String get profileSaved => '个人资料已保存。';

  @override
  String get allergies => '过敏';

  @override
  String get addAllergyHint => '输入一项过敏';

  @override
  String get addAllergy => '加入过敏';

  @override
  String get currentPassword => '当前密码';

  @override
  String get newPassword => '新密码';

  @override
  String get confirmNewPassword => '确认新密码';

  @override
  String get changePassword => '更改密码';

  @override
  String get updating => '更新中...';

  @override
  String get enterCurrentPassword => '请输入当前密码。';

  @override
  String get differentPassword => '请选择另一个密码。';

  @override
  String get retry => '再试一次';

  @override
  String get logOut => '退出';

  @override
  String get videoNotAvailable => '视频问诊尚未开放';

  @override
  String get videoNotAvailableMessage => '你现在可以先预约时间。视频通话准备好后会在这里打开。';

  @override
  String get teal => '青绿色';

  @override
  String get blue => '蓝色';

  @override
  String get green => '绿色';

  @override
  String get purple => '紫色';

  @override
  String get orange => '橙色';

  @override
  String get typeGeneralPractice => '全科';

  @override
  String get typeFamilyMedicine => '家庭医学';

  @override
  String get typeInternalMedicine => '内科';

  @override
  String get typePaediatrics => '儿科';

  @override
  String get typeObstetrics => '妇产科';

  @override
  String get typeSurgery => '外科';

  @override
  String get typeOrthopaedics => '骨科';

  @override
  String get typeDermatology => '皮肤科';

  @override
  String get typePsychiatry => '精神科';

  @override
  String get typeOphthalmology => '眼科';

  @override
  String get typeOtorhinolaryngology => '耳鼻喉科';

  @override
  String get typeCardiology => '心脏科';

  @override
  String get msgUsernameOrPassword => '用户名或密码不正确。';

  @override
  String get msgCannotReach => '无法连接服务。请检查网络后再试。';

  @override
  String get msgUsernameUsed => '这个用户名已被使用。';

  @override
  String get msgEmailUsed => '这个邮箱已被使用。';

  @override
  String get msgSignInFailed => '登录失败。请再试一次。';

  @override
  String get msgChooseRole => '请选择患者或医生。';

  @override
  String get msgCouldNotCreate => '无法创建账号。';

  @override
  String get msgRequestFailed => '请求失败。请再试一次。';

  @override
  String get msgSignInAgain => '请重新登录。';

  @override
  String get msgProfileUnread => '无法读取个人资料。';

  @override
  String get msgAccountUnavailable => '账号服务暂时无法使用。请稍后再试。';

  @override
  String get msgProfileFailed => '个人资料请求失败。';

  @override
  String get msgPasswordUpdated => '密码已更新。';

  @override
  String get msgCurrentPasswordWrong => '当前密码不正确。';

  @override
  String get msgEnterBothPasswords => '请输入当前密码和新密码。';

  @override
  String get msgDescriptionLimit => '简介请保持在 280 字以内。';

  @override
  String get msgCouldNotSaveProfile => '无法保存个人资料。';

  @override
  String get msgBadPhoto => '请选择小于 512 KB 的 JPEG、PNG 或 WebP 图片。';

  @override
  String get msgChooseDoctorTypes => '请从列表中选择医生科室。';

  @override
  String get msgAllergiesList => '请以列表输入过敏。';

  @override
  String get msgAllergyCount => '过敏项目请保持在 20 项以内。';

  @override
  String get msgAllergyName => '请输入简短的过敏名称。';

  @override
  String get msgAllergyLength => '每项过敏请保持在 40 字以内。';

  @override
  String get msgAppointmentUnread => '无法读取预约列表。';

  @override
  String get msgAppointmentFailed => '预约请求失败。';

  @override
  String get msgSlotTaken => '你在这个时间已经有时段。';

  @override
  String get msgOnlyDoctor => '只有医生可以新增时段。';

  @override
  String get msgOnlyPatient => '只有患者可以预约时段。';

  @override
  String get msgSlotGone => '这个时段已不能预约。';

  @override
  String get msgAppointmentMissing => '找不到这项预约。';

  @override
  String get msgCannotChange => '你不能更改这项预约。';
}

/// The translations for Chinese, using the Han script (`zh_Hant`).
class AppLocalizationsZhHant extends AppLocalizationsZh {
  AppLocalizationsZhHant() : super('zh_Hant');

  @override
  String get appTitle => '遠距醫療數位平台';

  @override
  String get appTagline => '把遠距照護、預約和後續跟進放在同一個地方。';

  @override
  String get username => '使用者名稱';

  @override
  String get password => '密碼';

  @override
  String get email => '電郵';

  @override
  String get confirmPassword => '確認密碼';

  @override
  String get enterUsername => '請輸入使用者名稱';

  @override
  String get enterPassword => '請輸入密碼';

  @override
  String get enterUsernameAndPassword => '請輸入使用者名稱和密碼。';

  @override
  String get enterValidEmail => '請輸入有效的電郵。';

  @override
  String get usernameRule => '請使用 3 至 40 個英文字母、數字、點、底線或連字號。';

  @override
  String get atLeast8 => '請至少使用 8 個字元。';

  @override
  String get samePasswordTwice => '請輸入兩次相同的密碼。';

  @override
  String get signIn => '登入';

  @override
  String get continueAs => '直接登入';

  @override
  String get createAccount => '建立帳號';

  @override
  String get forgotPassword => '忘記密碼？';

  @override
  String get resetPasswordTitle => '重設密碼';

  @override
  String get resetPasswordHint => '輸入帳號的電郵。寄出重設電郵的功能尚未接上。';

  @override
  String get sendResetLink => '傳送重設連結';

  @override
  String get resetEmailNotSent => '重設電郵尚未寄出。';

  @override
  String get createAccountAction => '建立帳號';

  @override
  String get creating => '建立中...';

  @override
  String get showPassword => '顯示密碼';

  @override
  String get hidePassword => '隱藏密碼';

  @override
  String get patient => '病人';

  @override
  String get doctor => '醫生';

  @override
  String get admin => '管理員';

  @override
  String welcomeBack(String name) {
    return '歡迎回來，$name';
  }

  @override
  String get doctorDashboard => '醫生主頁';

  @override
  String get patientDashboard => '病人主頁';

  @override
  String get adminDashboard => '管理員主頁';

  @override
  String get navHome => '主頁';

  @override
  String get navAppointments => '預約';

  @override
  String get navMessages => '訊息';

  @override
  String get noMessages => '還沒有訊息。';

  @override
  String get noMessagesHint => '可以從預約向醫生或病人傳訊息。';

  @override
  String get messageAction => '傳訊息';

  @override
  String get send => '傳送';

  @override
  String get messageHint => '輸入訊息';

  @override
  String get messageSent => '已傳送';

  @override
  String get messageRead => '已讀';

  @override
  String get patientProfile => '病人資料';

  @override
  String get msgEnterMessage => '請輸入訊息。';

  @override
  String get msgMessageTooLong => '訊息請保持在 500 字以內。';

  @override
  String get msgCannotMessageYourself => '不能傳訊息給自己。';

  @override
  String get msgPersonNotFound => '找不到這個人。';

  @override
  String get msgMessagesUnread => '無法讀取訊息。';

  @override
  String get msgMessageFailed => '訊息要求失敗。';

  @override
  String get navConsultation => '諮詢';

  @override
  String get navProfile => '個人資料';

  @override
  String get overview => '概覽';

  @override
  String get coreServices => '主要服務';

  @override
  String get otherServices => '其他服務';

  @override
  String get nextAppointment => '下一個預約';

  @override
  String get notScheduled => '尚未安排';

  @override
  String get noActiveOrder => '沒有進行中的訂單';

  @override
  String get appointmentsSubtitle => '預約一次遠距診症';

  @override
  String get consultationTitle => '諮詢';

  @override
  String get consultationSubtitle => '與醫生對話';

  @override
  String get sickLeave => '病假紙';

  @override
  String get sickLeaveSubtitle => '只供閱讀的證明';

  @override
  String get payment => '付款';

  @override
  String get paymentSubtitle => '診症和送藥費用';

  @override
  String get medicationDelivery => '藥物配送';

  @override
  String get medicationDeliverySubtitle => '追蹤處方藥物';

  @override
  String get aiChatbot => '人工智能助手';

  @override
  String get aiChatbotSubtitle => '指引和提問';

  @override
  String get discussion => '討論';

  @override
  String get discussionSubtitle => '向醫生公開提問';

  @override
  String get askQuestion => '提出問題';

  @override
  String get questionTitle => '標題';

  @override
  String get questionBody => '你的問題';

  @override
  String get postQuestion => '發佈';

  @override
  String get noDiscussions => '還沒有問題。';

  @override
  String get noDiscussionsHint => '所有人都可以看問題。只有醫生可以回覆，多於一位醫生也可以回覆。';

  @override
  String get discussionOpen => '待回覆';

  @override
  String get discussionAnswered => '已回覆';

  @override
  String get publicReply => '公開回覆';

  @override
  String get noRepliesYet => '還沒有回覆。';

  @override
  String get replyHint => '寫下建議或簡單說明';

  @override
  String get searchPosts => '搜尋帖子';

  @override
  String get noMatchingPosts => '沒有相符的帖子。';

  @override
  String get editReply => '編輯回覆';

  @override
  String get saveReply => '儲存';

  @override
  String get confirmRemoveReplyTitle => '移除這則回覆？';

  @override
  String get confirmRemoveReplyMessage => '這則回覆會被刪除。';

  @override
  String get msgOnlyReplyAuthor => '只有寫下這則回覆的醫生可以更改。';

  @override
  String get replyAction => '回覆';

  @override
  String get allComments => '全部回覆';

  @override
  String get myComments => '我的回覆';

  @override
  String get noStoredReplies => '你還沒有收藏回覆。';

  @override
  String get likeAction => '讚好';

  @override
  String get storeAction => '收藏';

  @override
  String get storedAction => '已收藏';

  @override
  String get publicDiscussions => '公開討論';

  @override
  String get myDiscussions => '我的討論';

  @override
  String get noMyDiscussions => '你還沒有發佈討論。';

  @override
  String get myResponses => '我的回覆';

  @override
  String get noMyResponses => '你還沒有回覆討論。';

  @override
  String get confirmRemovePostTitle => '移除這則帖子？';

  @override
  String get confirmRemovePostMessage => '這則帖子和回覆會被刪除。';

  @override
  String get msgOnlyPosterCanRemove => '只有發帖的人可以移除。';

  @override
  String replyCount(int count) {
    return '$count 則回覆';
  }

  @override
  String get msgOnlyPatientCanAsk => '只有病人可以發問。';

  @override
  String get msgOnlyDoctorCanReply => '只有醫生可以回覆。';

  @override
  String get msgEnterTitle => '請輸入標題。';

  @override
  String get msgTitleTooLong => '標題請少於 120 個字。';

  @override
  String get msgEnterQuestion => '請輸入問題。';

  @override
  String get msgQuestionTooLong => '問題請少於 1000 個字。';

  @override
  String get msgEnterReply => '請輸入回覆。';

  @override
  String get msgReplyTooLong => '回覆請少於 1000 個字。';

  @override
  String get msgQuestionNotFound => '找不到這個問題。';

  @override
  String get msgDiscussionFailed => '討論請求失敗。';

  @override
  String get msgDiscussionsUnread => '無法讀取討論列表。';

  @override
  String get iotHealth => '健康裝置';

  @override
  String get iotHealthSubtitle => '穿戴裝置讀數';

  @override
  String get serviceUnavailable => '這項服務尚未開放。';

  @override
  String get close => '關閉';

  @override
  String patientLine(String name) {
    return '病人：$name';
  }

  @override
  String get unknown => '未知';

  @override
  String get noPatientYet => '尚未有病人';

  @override
  String get openForPatients => '開放給病人';

  @override
  String get noAppointment => '沒有預約';

  @override
  String get noAppointmentYet => '你還沒有預約。';

  @override
  String get noAppointmentOnDay => '這一天沒有預約。';

  @override
  String get noAppointmentsYet => '尚未有預約';

  @override
  String get doctorsHaveNotPublished => '醫生尚未公布時段。';

  @override
  String get appointmentsUnavailable => '暫時無法載入預約';

  @override
  String get makeAppointment => '建立預約時段';

  @override
  String get bookAppointment => '預約看診';

  @override
  String get bookThisTime => '預約這個時段';

  @override
  String get reasonForVisit => '看診原因';

  @override
  String get enterShortReason => '請輸入簡短的看診原因。';

  @override
  String get book => '預約';

  @override
  String get openTimes => '可預約時段';

  @override
  String get doctorName => '醫生姓名';

  @override
  String get viewDoctorProfile => '查看資料';

  @override
  String get doctorProfile => '醫生資料';

  @override
  String get noDescription => '尚未填寫簡介。';

  @override
  String get allTypes => '全部科別';

  @override
  String get doctorTypeLabel => '醫生科別';

  @override
  String get sort => '排序';

  @override
  String get soonest => '最近的時間';

  @override
  String get latest => '最遠的時間';

  @override
  String get nameAz => '姓名 A–Z';

  @override
  String get nameZa => '姓名 Z–A';

  @override
  String get noOpenTimes => '暫時沒有可預約時段。醫生尚未公布時間。';

  @override
  String get noOpenTimesMatch => '沒有符合這個搜尋的時段。';

  @override
  String get calendar => '日曆';

  @override
  String get list => '列表';

  @override
  String get previousMonth => '上個月';

  @override
  String get nextMonth => '下個月';

  @override
  String get cancelSlot => '取消時段';

  @override
  String get cancelBooking => '取消預約';

  @override
  String get confirmCancelTitle => '要取消這項預約嗎？';

  @override
  String get confirmCancelSlotMessage => '病人將不能再預約這個時段。';

  @override
  String get confirmCancelVisitMessage => '這次看診會被取消。';

  @override
  String get confirmCancelBookingMessage => '這項預約會取消，時段會重新開放。';

  @override
  String get confirmRemoveTitle => '要刪除這項預約嗎？';

  @override
  String get confirmRemoveMessage => '這筆已取消的紀錄會被刪除。';

  @override
  String get remove => '刪除';

  @override
  String get keep => '保留';

  @override
  String get msgOnlyCancelled => '只有已取消的預約可以刪除。';

  @override
  String get chooseFutureTime => '請選擇一個未來的時間。';

  @override
  String get statusAvailable => '可預約';

  @override
  String get statusScheduled => '已預約';

  @override
  String get statusCancelled => '已取消';

  @override
  String get settings => '設定';

  @override
  String get language => '語言';

  @override
  String get languageStaysOnDevice => '語言設定只保存在這台裝置。';

  @override
  String get appearance => '外觀';

  @override
  String get darkMode => '深色模式';

  @override
  String get darkModeSubtitle => '在淺色和深色之間切換';

  @override
  String get appColor => '應用程式顏色';

  @override
  String get colorStaysOnDevice => '顏色和深色模式只保存在這台裝置。';

  @override
  String get fontSize => '字體大小';

  @override
  String get fontSizeSmall => '小';

  @override
  String get fontSizeNormal => '標準';

  @override
  String get fontSizeLarge => '大';

  @override
  String get fontSizeExtra => '特大';

  @override
  String get fontSizeStaysOnDevice => '字體大小只保存在這台裝置，並套用到每一頁。';

  @override
  String get account => '帳號';

  @override
  String get passwordSection => '密碼';

  @override
  String get uploadPhoto => '上傳相片';

  @override
  String get removePhoto => '移除相片';

  @override
  String get description => '簡介';

  @override
  String get saveProfile => '儲存個人資料';

  @override
  String get saving => '儲存中...';

  @override
  String get profileSaved => '個人資料已儲存。';

  @override
  String get allergies => '過敏';

  @override
  String get addAllergyHint => '輸入一項過敏';

  @override
  String get addAllergy => '加入過敏';

  @override
  String get currentPassword => '目前密碼';

  @override
  String get newPassword => '新密碼';

  @override
  String get confirmNewPassword => '確認新密碼';

  @override
  String get changePassword => '變更密碼';

  @override
  String get updating => '更新中...';

  @override
  String get enterCurrentPassword => '請輸入目前密碼。';

  @override
  String get differentPassword => '請選擇另一個密碼。';

  @override
  String get retry => '再試一次';

  @override
  String get logOut => '登出';

  @override
  String get videoNotAvailable => '視像診症尚未開放';

  @override
  String get videoNotAvailableMessage => '你現在可以先預約時間。視像通話準備好後會在這裡開啟。';

  @override
  String get teal => '青綠色';

  @override
  String get blue => '藍色';

  @override
  String get green => '綠色';

  @override
  String get purple => '紫色';

  @override
  String get orange => '橙色';

  @override
  String get typeGeneralPractice => '全科';

  @override
  String get typeFamilyMedicine => '家庭醫學';

  @override
  String get typeInternalMedicine => '內科';

  @override
  String get typePaediatrics => '兒科';

  @override
  String get typeObstetrics => '婦產科';

  @override
  String get typeSurgery => '外科';

  @override
  String get typeOrthopaedics => '骨科';

  @override
  String get typeDermatology => '皮膚科';

  @override
  String get typePsychiatry => '精神科';

  @override
  String get typeOphthalmology => '眼科';

  @override
  String get typeOtorhinolaryngology => '耳鼻喉科';

  @override
  String get typeCardiology => '心臟科';

  @override
  String get msgUsernameOrPassword => '使用者名稱或密碼不正確。';

  @override
  String get msgCannotReach => '無法連接服務。請檢查網絡後再試。';

  @override
  String get msgUsernameUsed => '這個使用者名稱已被使用。';

  @override
  String get msgEmailUsed => '這個電郵已被使用。';

  @override
  String get msgSignInFailed => '登入失敗。請再試一次。';

  @override
  String get msgChooseRole => '請選擇病人或醫生。';

  @override
  String get msgCouldNotCreate => '無法建立帳號。';

  @override
  String get msgRequestFailed => '要求失敗。請再試一次。';

  @override
  String get msgSignInAgain => '請重新登入。';

  @override
  String get msgProfileUnread => '無法讀取個人資料。';

  @override
  String get msgAccountUnavailable => '帳號服務暫時無法使用。請稍後再試。';

  @override
  String get msgProfileFailed => '個人資料要求失敗。';

  @override
  String get msgPasswordUpdated => '密碼已更新。';

  @override
  String get msgCurrentPasswordWrong => '目前密碼不正確。';

  @override
  String get msgEnterBothPasswords => '請輸入目前密碼和新密碼。';

  @override
  String get msgDescriptionLimit => '簡介請保持在 280 字以內。';

  @override
  String get msgCouldNotSaveProfile => '無法儲存個人資料。';

  @override
  String get msgBadPhoto => '請選擇小於 512 KB 的 JPEG、PNG 或 WebP 圖片。';

  @override
  String get msgChooseDoctorTypes => '請從清單中選擇醫生科別。';

  @override
  String get msgAllergiesList => '請以清單輸入過敏。';

  @override
  String get msgAllergyCount => '過敏項目請保持在 20 項以內。';

  @override
  String get msgAllergyName => '請輸入簡短的過敏名稱。';

  @override
  String get msgAllergyLength => '每項過敏請保持在 40 字以內。';

  @override
  String get msgAppointmentUnread => '無法讀取預約清單。';

  @override
  String get msgAppointmentFailed => '預約要求失敗。';

  @override
  String get msgSlotTaken => '你在這個時間已經有時段。';

  @override
  String get msgOnlyDoctor => '只有醫生可以新增時段。';

  @override
  String get msgOnlyPatient => '只有病人可以預約時段。';

  @override
  String get msgSlotGone => '這個時段已不能預約。';

  @override
  String get msgAppointmentMissing => '找不到這項預約。';

  @override
  String get msgCannotChange => '你不能更改這項預約。';
}
