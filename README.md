# fluttercare168
#0985463816 / admin

ChatRoomViewSet 的列表, 新增
users : 2,4
http://localhost:8000/api/chatroom

MessageViewSet 的列表, 新增
body form-data: case : 1 , content : Ok
http://localhost:8000/api/messages/?chatroom=1

SystemMessageViewSet 的列表
http://localhost:8000/api/system_messages

20220905
1.做"申請預訂並聊聊" 完成
v 2.Search Servant Detail 的 reviews 頁
==========
v 2.後台 所有文章類別, 新增/修改文章類別
v 3.後台 資料審核, 資料審核詳細頁
v 4.案件明細頁 => 按我退訂鈕, 退款頁

20220901
1.做"申請預訂並聊聊"

20220831
1.週間的部分
Dialog => 吃 userModel 的 data => 去更新 userModel 的 data (不需要返回 data)
Home => 吃 userModel 的 data (用 Consumer)
Requirement => 吃 userModel 的 data (用 Consumer)
2.關於命名
a.如果是 list => 取複數名 
ex. users or  user_list   => [User, User, User]
如果 User 不是一個 model, 而是存 String, 那應該取 user_strings => ["Jorge","Bob","ARod"]
=> 不要偶爾用 users, 偶爾用 user_list
=> 大部分工程師都是用 users
3.關於變數
a.不需要設變數, 不要設變數
b.不需要看到這個變數的人, 不要讓他看到

20220830
1.首頁週間選擇
2.start_end_time 的時間選擇, 先設為整點
3.完成search
4.填寫需求單的 詢問照顧者是否有意願~

20220824
1.修正過往的 api 問題
2.做填寫需求單的部分(用 notifier_model 處理)

20220822
1.我的服務設定 / 服務項目頁

20220819
1.我接的案詳細頁 bug
2.照護員推薦
http://localhost:8000/api/recommend_servants/

20220817
1.日期能跟隨文字
2.串訂單資訊
http://localhost:8000/api/orders/[:id]

20220816
1.把 case 做成對話筐放入
2.塞圖片

20220815
1.看怎麼買 https://github.com/JohannesMilke/chat_app_ui
2.測看看 chat room list 跟 message list 的 api

20220809
1.轉圈圈問題

20220808
1.check 加入/移除 service_model 的 userWeekDayTimes
2.完成 language 的部分

20220805
1.在 時段 的地方, 寫一個 for loop 產生 7 個 row (Language 也是類似做法)
2.Get 資料回來, 加入資料比對, if 有資料就打勾
a.把取回的資料存在 serviceModel
var serviceModel = context.read<ServiceModel>();
serviceModel.checkedUserWeekDayTimes.add(weeDayTime)
b.需要比對的時候,再從 serviceModel 取出來比對
==============
3.check 加入/移除 service_model 的 userWeekDayTimes

20220804
0.先把填好的資料暫存到 notifier_model/user_model

1.UserWeekDayTime 用 get, put method
weekday: 1,3,6 weektime: 0900:2100,1000:1900,1100:1400
http://localhost:8000/api/user/user_weekdaytimes
2.User Language 用 get, put method
language: 1,3,5,6,7,8  remark_original:排灣族語  remark_others: 法語
http://localhost:8000/api/user/user_languages
3.UpdateUserCareType 的修改
is_home:TRUE, is_hospital:TRUE, home: 300,1650,3350 hospital: 330,1700,3450
http://localhost:8000/api/user/update_user_caretype
4.服務地區
UserLocations的修改
locations: 39,57 tranfer_fee: 300,500
http://localhost:8000/api/user/user_locations

x 5.服務項目
UserService 的修改
services: 2,4,6,8  increase_prices: 20,25
http://localhost:8000/api/user/user_services

6.UpdateUserInfoImage 更新 about_me 跟 background_image
image: file, about_me: 我是誰
http://localhost:8000/api/user/update_user_info_images

20220803
1.上傳圖片
put method, licence_id:4, : image: file  
http://localhost:8000/api/user/user_license_images
2.關於我相關文件上傳

20220802
1.Dialog 送出評價後, 要重新 load
2.我的文件上傳
2.0 選圖(已經做了)
2.1 上傳圖片
put method, licence_id:4, : image: file  
http://localhost:8000/api/user/user_license_images

20220728
1.評價頁的部分
2.給評價改成 dialog 好了~

20220727
1.我發的需求案件
http://localhost:8000/api/need_cases/
* Put Review Update 給服務者的評論
  http://localhost:8000/api/reviews/1?servant_rating=5&servant_comment=評論內容
2.找案件
http://localhost:8000/api/search_cases/?city=6&county=77&start_datetime=2022-07-10T00:00:00Z&end_datetime=2022-08-05T00:00:00Z&care_type=hospital

20220726
1.my_case_detail_page => 給案主評價, 查看案主給的評價
2.現在 api/user/me 有把相關 user 資料返回, 所以
a.進入相關頁面時, 要帶入 user 資料
b.當 update 資料時, 也要 update userModel

20220722
1.ServantCase 改命名為 Case
2.my_case_detail 的 parse 修正, 用上各個 Model
3.寫一個 Review model
4.修正 search_case_page 的 _getCaseList

20220721
1.修正 search_case 的 choose date
2.修改 chosen_condition 時, 要帶入 _getCaseList
3.我接的案列表, detail 

20220720
1.把 Update ATM 的欄位改對
2.會員中心的登出按紐用 consumer
3.找案件, 我接的案, 我發的案件需求
a.找案件的 filter 資料要帶入 _getCaseList
b.找案件的 filter 條件為 0 時, filter 欄要縮起來
c.日期不用顯示 weekday
d.找案件的各個 filter 條件, 留一個就好了

CaseSearch 的列表, 查詢, 新增, 修改
http://localhost:8000/api/search_cases/?city=6&start_datetime=2022-07-10T00:00:00Z&end_datetime=2022-08-05T00:00:00Z&care_type=hospital
ServantCaseViewSet 的列表, 查詢
http://localhost:8000/api/servant_cases/
NeedCaseViewSet 的列表, 查詢
http://localhost:8000/api/need_cases/

20220719
？1.Line 的註冊/登入
？2.會員中心的版面調整, 及登出按鈕移到下方
3.Update ATM 收款方式
body form-data:ATMInfoBankCode : xxx  ATMInfoBranchBankCode: xxx accounts: xxx
http://localhost:8000/api/user/update_ATM_info

20220718
1.檢查 City, County 資料是否正確
2.把固定的資料寫成 Model, 並把資料寫死 License, Language, Service, DiseaseCondition, BodyCondition
3.User login (0985463816/admin) => /api/user/token, /api/user/me/, /api/user/create