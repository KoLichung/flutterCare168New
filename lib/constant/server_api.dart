
class ServerApi {
  static const _HOST ='care168.com.tw';
  // static const _HOST = 'localhost:8000';
  static const host = 'https://care168.com.tw/';
  static const IMG_PATH = host + 'media/';

  static const ABOUT_URL = host + 'about';
  static const TERMS_SERVICE_URL = host + 'terms_of_service';
  static const PRIVACY_POLICY_URL = host + 'privacy_policy';

  static const PATH_CREATE_USER = '/api/user/create/';
  static const PATH_USER_TOKEN = '/api/user/token/';
  static const PATH_USER_DATA = '/api/user/me/';
  static const PATH_USER_UPDATE_ATM_INFO = '/api/user/update_ATM_info';
  static const PATH_USER_USER_LICENSE_IMAGES = '/api/user/user_license_images';
  static const PATH_USER_WEEK_DAY_TIMES = '/api/user/user_weekdaytimes';
  static const PATH_USER_LANGUAGES = '/api/user/user_languages';
  static const PATH_USER_SERVICES = '/api/user/user_services';
  static const PATH_USER_SERVICE_LOCATIONS = '/api/user/user_locations';
  static const PATH_UPDATE_USER_HEAD_IMAGE = '/api/user/update_user_images';
  static const PATH_UPDATE_USER_BACKGROUND_IMAGE = '/api/user/update_user_background_image';
  static const PATH_GET_UPDATE_USER_FCM_NOTIFY = '/api/user/get_update_user_fcm_notify';
  static const PATH_DELETE_USER = '/api/user/deleteuser/';
  static const PATH_USER_UPDATE_PASSWORD = '/api/user/update_user_password';

  static const PATH_GET_SMS_VERIFY = '/api/sms_verify';
  static const PATH_RESET_PASSWORD_SMS_VERIFY = "/api/reset_password_sms_verify";
  static const PATH_RESET_PASSWORD_SMS_PASSWORD = "/api/reset_password_sms_password";

  static const PATH_REGISTER_DEVICE = "/messageApp/device_register";

  static const PATH_SEARCH_SERVANTS = '/api/search_servants/';
  static const PATH_CARER_LOCATIONS = '/api/userServiceLocations/';

  static const PATH_SEARCH_CASES = '/api/search_cases/';
  static const PATH_SERVANT_CASES = '/api/servant_cases/';
  static const PATH_NEED_CASES = '/api/need_cases/';
  static const PATH_CREATE_CASE = '/api/create_case';
  static const PATH_APPLY_CASE = '/api/apply_case';

  static const PATH_RECOMMEND_SERVANTS = '/api/recommend_servants/';

  static const PATH_REVIEW = '/api/reviews/';
  static const PATH_SERVANT_PUT_REVIEW = '/api/servant_put_review/';

  static const PATH_CHATROOM = '/api/chatroom/';
  static const PATH_MESSAGES = '/api/messages';
  static const PATH_SYSTEM_MESSAGES = '/api/system_messages/';
  static const PATH_ORDERS = '/api/orders/';
  static const PATH_CREATE_SERVANT_ORDER = '/api/create_servant_order';
  static const PATH_EDIT_CASE_ORDER = '/api/edit_case';
  static const PATH_CANCEL_ORDER = '/api/earlytermination';

  static const PATH_BLOG_CATEGORIES = '/api/blog_categories/';
  static const PATH_BLOG_POST = '/api/blog_posts/';

  static const PATH_GET_CURRENT_VERSION= '/api/get_current_version';

  static getBlogDetailUrl(int blogID){
    return host + '/news_detail?blogpost=' + blogID.toString();
  }

  static getCarerUrl(int servantId){
    return host + 'search_carer_detail?servant=' + servantId.toString();
  }

  static Uri standard({String? path, Map<String, String>? queryParameters}) {
    print(Uri.https(_HOST, '$path', queryParameters));
    return Uri.https (_HOST, '$path', queryParameters);
  }
}