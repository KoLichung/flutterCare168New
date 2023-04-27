import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:fluttercare168/constant/server_api.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:fluttercare168/notifier_model/user_model.dart';

class BankAccount extends StatefulWidget {
  const BankAccount({Key? key}) : super(key: key);

  @override
  _BankAccountState createState() => _BankAccountState();
}

class _BankAccountState extends State<BankAccount> {

  TextEditingController bankCodeController = TextEditingController();
  TextEditingController bankBranchCodeController = TextEditingController();
  TextEditingController bankAccountNumberController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    var userModel = context.read<UserModel>();
    if(userModel.user!.aTMInfoBankCode == null){
      bankCodeController.text = '';
    } else {
      bankCodeController.text = userModel.user!.aTMInfoBankCode!;
    }
    if(userModel.user!.aTMInfoBranchBankCode == null){
      bankBranchCodeController.text = '';
    } else {
      bankBranchCodeController.text = userModel.user!.aTMInfoBranchBankCode!;
    }
    if(userModel.user!.aTMInfoAccount == null){
      bankAccountNumberController.text = '';
    } else {
      bankAccountNumberController.text = userModel.user!.aTMInfoAccount!;
    }
    // bankCodeController.text = userModel.user!.aTMInfoBankCode!;
    // bankBranchCodeController.text = userModel.user!.aTMInfoBranchBankCode!;
    // bankAccountNumberController.text = userModel.user!.aTMInfoAccount!;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('收款方式'),
        // actions: [
        //   TextButton(
        //     child: const Text('儲存',style: TextStyle(color: Colors.white),),
        //     onPressed: (){
        //       var userModel = context.read<UserModel>();
        //       _putUpdateBankAccount(userModel.token!, bankCodeController.text, bankBranchCodeController.text, bankAccountNumberController.text);
        //       userModel.updateBankAccount(bankCodeController.text, bankBranchCodeController.text, bankAccountNumberController.text);
        //       },
        //   )],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('請輸入您的收款帳戶資訊', style: TextStyle(fontWeight: FontWeight.bold),),
                const SizedBox(height: 20,),
                const Text('金融機構代碼'),
                const SizedBox(height: 6,),
                TextField(
                  // controller: bankCodeController,
                  controller: bankCodeController,
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly,],
                  enabled: false,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    filled: true,
                    fillColor: Color(0xffE5E5E5),
                  ),
                ),
                const SizedBox(height: 20,),
                const Text('金融機構分行代碼'),
                const SizedBox(height: 6,),
                TextField(
                  controller: bankBranchCodeController,
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly,],
                  enabled: false,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    filled: true,
                    fillColor: Color(0xffE5E5E5),
                  ),
                ),
                const SizedBox(height: 20,),
                const Text('金融機構帳戶帳號'),
                const SizedBox(height: 6,),
                TextField(
                  controller: bankAccountNumberController,
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly,],
                  enabled: false,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    filled: true,
                    fillColor: Color(0xffE5E5E5),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future _putUpdateBankAccount (String token, String bankCode, String branchCode, String accountNum)async{
    String path = ServerApi.PATH_USER_UPDATE_ATM_INFO;
    try{
      final bodyParams ={
        'ATMInfoBankCode':bankCode,
        'ATMInfoBranchBankCode':branchCode,
        'ATMInfoAccount': accountNum,
      };

      final response = await http.put(ServerApi.standard(path:path),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'token $token'
        },
        body: jsonEncode(bodyParams),
      );
      // print(response.body);
      if(response.statusCode == 200){
        print('success update order atm info');
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("成功更新！"),
            )
        );
      }

    } catch (e){
      print(e);
    }

  }
}
