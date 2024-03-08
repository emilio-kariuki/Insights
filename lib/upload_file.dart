import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:insights/supabase_config.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UploadPage extends StatefulWidget {
  const UploadPage({super.key});

  @override
  State<UploadPage> createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> {
  File? _file;
  bool isLoading = false;
  Future<bool> uploadCsv({
    required File file,
    required String goal1,
    required String phone,
  }) async {
    try {
      debugPrint(file.toString());
      debugPrint(goal1);

      debugPrint(phone);
      final imageKey = 'insights/${DateTime.now().millisecondsSinceEpoch}.csv';
      await supabase.storage.from('picsa').upload(imageKey, file,
          retryAttempts: 3,
          fileOptions: FileOptions(
            cacheControl: 'public, max-age=3600',
            contentType: 'text/csv',
          ));
      debugPrint("The file has been inserted");
      // await supabase.from('Insights').insert(
      //   {
      //     'id': DateTime.now().millisecondsSinceEpoch.toString(),
      //     'goal1': goal1,
      //     'goal2': goal2,
      //     'goal3': goal3,
      //     'phone': phone,
      //     'url': supabase.storage.from('picsa').getPublicUrl(imageKey),
      //   },
      // );
      final request = jsonEncode({
        'goal1': goal1,
        'phone': phone,
      });
      await Dio().post("https://vfd2wfkp-5000.uks1.devtunnels.ms/user", data: request);
      return true;
    } catch (e) {
      debugPrint(e.toString());
      throw Exception('Error uploading file');
    }
  }

//text controllers
  final goal1Controller = TextEditingController();
  final goal2Controller = TextEditingController();
  final goal3Controller = TextEditingController();
  final phoneController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  //dispose
  @override
  void dispose() {
    goal1Controller.dispose();
    goal2Controller.dispose();
    goal3Controller.dispose();
    phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Center(
          child: isLoading
              ? const CircularProgressIndicator()
              : Form(
                  key: formKey,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.1,
                          ),
                          TextFormField(
                            controller: goal1Controller,
                            decoration: const InputDecoration(
                              labelText: 'Goal 1',
                              hintText: 'Enter goal 1',
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Please enter goal 1';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          TextFormField(
                            controller: phoneController,
                            keyboardType: TextInputType.phone,
                            decoration: const InputDecoration(
                              labelText: 'Phone Number ',
                              hintText: 'Enter phone number',
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Please enter phone number';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          const Text("Upload the CSV file"),
                          const SizedBox(
                            height: 20,
                          ),
                          //display the name of the file
                          if (_file != null) Text(_file!.path.split('/').last),

                          OutlinedButton(
                            onPressed: () async {
                              final file = await FilePicker.platform.pickFiles(
                                type: FileType.custom,
                                allowedExtensions: ['csv'],
                              );
                              if (file != null) {
                                setState(() {
                                  _file = File(file.files.single.path!);
                                });
                              } else {
                                print("No file selected");
                              }
                            },
                            style: OutlinedButton.styleFrom(
                                minimumSize: const Size(200, 45)),
                            child: const Text('Upload'),
                          ),
                          if (_file != null)
                            OutlinedButton(
                              onPressed: () async {
                                if (formKey.currentState!.validate()) {
                                  setState(() {
                                    isLoading = true;
                                  });
                                  final goal1 = goal1Controller.text;
                                  final phone = phoneController.text;
                                  final result = await uploadCsv(
                                    file: _file!,
                                    goal1: goal1,
                                    
                                    phone: phone,
                                  );
                                  if (result) {
                                    //clear the file
                                    _file = null;
                                    //clear the form
                                    goal1Controller.clear();
                                    goal2Controller.clear();

                                    goal3Controller.clear();
                                    phoneController.clear();

                                    setState(() {
                                      isLoading = false;
                                    });
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content:
                                            Text('File uploaded successfully'),
                                      ),
                                    );
                                  } else {
                                    setState(() {
                                      isLoading = false;
                                    });

                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Error uploading file'),
                                      ),
                                    );
                                  }
                                }
                              },
                              style: OutlinedButton.styleFrom(
                                  minimumSize: const Size(200, 45)),
                              child: const Text('Send to server'),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}
