var thisYear = DateTime.now().year.toString();

class Strings {
  Strings._();

  // version application

  static const String msgDioErrorTypeCANCEL =
      "Request to API server was cancelled";

  // "Request to API server was cancelled !"; ການຊື່ມຕໍ່ຖືກຍົກເລີກແລ້ວ !
  // ignore: constant_identifier_names
  static const String msgDioErrorTypeCONNECT_TIMEOUT =
      "Connection timeout with API server";

  // "Connection timeout with API server !"; ໝົດເວລາການເຊື່ອມຕໍ່
  static const String msgDioErrorTypeDEFAULT =
      "Connection to server failed, Please check your internet connection";

  // "Connection to API server failed due to internet connection !"; ບໍ່ສາມາດເຊື່ອຕໍ່ ກະລຸນາກວດສອບ ອິນເຕີເນັດ
  // ignore: constant_identifier_names
  static const String msgDioErrorTypeRECEIVE_TIMEOUT =
      "Receive timeout in connection with API server";

  // "Receive timeout in connection with API server !";ໝົດເວລາເຊື່ອມຕໍ່ກັບຈາກເຊີຟເວີ່
  // ignore: constant_identifier_names
  static const String msgDioErrorTypeSEND_TIMEOUT =
      "Send timeout in connection with API server";

  // "Send timeout in connection with API server !"; ການສົ່ງອອກໝົດເວລາເຊື່ອມຕໍ່ຈາກເຊີຟເວີ່
  static const String msgDioErrorTypeDEFAULTSOMETING = "Something went wrongs";

  // "Something went wrong !";ມີບາງຢ່າງຜິດພາດ ກະລຸນາລອງໃໝ່ພາຍຫຼັງ

  static const String msgStatusCode400 = "Bad request";

  // "Bad request !";
  static const String msgStatusCode401 = "Unauthorized";

  // "Unauthorized !"; ທ່ານບໍ່ໄດ້ຮັບອະນຸຍາດ !
  static const String msgStatusCode403 = "Forbidden";

  // "Not found !"; ທ່ານບໍ່ໄດ້ຮັບອະນຸຍາດ !
  static const String msgStatusCode404 = "Not found";

  // "Forbidden !";ທ່ານບໍ່ມີສິດຮ້ອງຂໍ
  static const String msgStatusCode413 = "Payload Too Large";

  // "Payload Too Large !";ຂໍ້ມູນໃຫຍ່ເກີນໄປ !
  static const String msgStatusCode422 = "Invalid email or password";

  // "Invalid email or password!"; ເບີ ຫຼຶ ລະຫັດຜ່ານ ບໍ່ຖືກຕ້ອງ!
  static const String msgStatusCode500 = "Internal server error";

  // "Internal server error !"; ເຊີຟເວີຂັດຂ້ອງຊົ່ວຄາວ ກະລຸນາລອງໃໝ່ພາຍຫຼັງ !
  static const String msgStatusCode503 = "Service Unavailable";

  // "Service Unavailable !"; ເຊີຟເວີ ເຮັດວຽກໜັກເກີນໄປ
  static const String msgStatusCodeDefault = "Oops something went wrong";

// "Oops something went wrong !"; ມີບາງຢ່າງຜິດພາດ ກະລຸນາລອງໃໝ່ພາຍຫຼັງ !

  ///POS
  static const String txtLaphak = "ວັນລາພັກທີຍັງເຫຼືອ";
  static const String txtWelcomeNCC = "Welcome to NCC Group";
  static const String txtPleas = "Please choose your login option below";
  static const String txtForget = "ລືມລະຫັດຜ່ານ";

  static const String txtAppName = "Seller_App";
  static const String txtVersion = "Version";
  static const String txtHome = "Home";
  static const String txtPassword = "Password";
  static const String txtInputID = "Input_ID";
  static const String txtInputPassword = "Input_Password";
  static const String txtLogin = "Login";
  static const String txtLoginSuccess = "Login_Success";
  static const String txtMenu = "Menu";
  static const String txtID = "ID";
  static const String txtDraw = "Draw";
  static const String txtDrawDate = "Draw-Date";
  static const String txtNo = "No";
  static const String txtDigit = "Digit";
  static const String txtAmount = "Amount";
  static const String txtDel = "Del";
  static const String txtSaleHeader = "Sale_Header";
  static const String txtCustomerPhone = "Customer_Phone";
  static const String txtTotal = "Total";
  static const String txt23456D = "23456D";
  static const String txt4Animals = "4_Animals";
  static const String txt2D = "2D";
  static const String txt3D = "3D";
  static const String txt4D = "4D";
  static const String txt5D = "5D";
  static const String txt6D = "6D";
  static const String txtSale = "Sale";
  static const String txtRandom = "Random";
  static const String txtShuffle = "Shuffle";
  static const String txtFullSet = "Full_Set";
  static const String txtPrint = "Print";
  static const String txtPrintTest = "Print_Test";
  static const String txtRegisterInformation = "Register_Information";
  static const String txtPromotionAnnouncement = "Promotion_Announcement";
  static const String txtLotteryResult = "Lottery_Result";
  static const String txtChangePassword = "Change_Password";
  static const String txtChangeLanguage = "Change_Language";
  static const String txtLogout = "Logout";
  static const String txtRemainingWallet = "Remaining_Wallet";
  static const String txtSellerID = "Seller_ID";
  static const String txtNameOfSeller = "Name_Of_Seller";
  static const String txtPhoneNumber = "Phone_Number";
  static const String txtBankName = "Bank_Name";
  static const String txtAccountNumber = "Account_Number";
  static const String txtAccountName = "Account_Name";
  static const String txtUpdate = "Update";
  static const String txtDatabaseException = "Database_Exception";
  static const String txtDate = "Date";
  static const String txtBill = "Bill";
  static const String txtCustomerPhoneNumber = "Customer_Phone_Number";
  static const String txtAnimal = "Animal";
  static const String txtCheckWinner = "Check_Winner";
  static const String txtSearch = "Search";
  static const String txtWiningDigit = "Wining_Digit";
  static const String txt2Digit6Digit = "2Digit_6Digit";
  static const String txt440Animals = "440_Animals";
  static const String txtPleaseChangePassword = "Please_Change_Password";
  static const String txtOldPassword = "Old_Password";
  static const String txtNewPassword = "New_Password";
  static const String txtConfirmPassword = "Confirm_Password";
  static const String txtCancel = "Cancel";
  static const String txtOkay = "Okay";
  static const String txtInputMoney = "InputMoney";
  static const String txtBack = "Back";
  static const String txtSetting = "Setting";
  static const String txtCount = "Count";
// static const String txt = "";
// static const String txt = "";
// static const String txt = "";
// static const String txt = "";
// static const String txt = "";
// static const String txt = "";
// static const String txt = "";
// static const String txt = "";
// static const String txt = "";
// static const String txt = "";
// static const String txt = "";
// static const String txt = "";
// static const String txt = "";
// static const String txt = "";
// static const String txt = "";
// static const String txt = "";
// static const String txt = "";
// static const String txt = "";
// static const String txt = "";
}
