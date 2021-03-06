import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:async/async.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import 'package:sillyhacks/Screens/profile.dart';
import 'dart:convert';

import 'package:sillyhacks/constants.dart';

class MyCameraScreen extends StatefulWidget {
  @override
  _MyCameraScreenState createState() => _MyCameraScreenState();
}

class _MyCameraScreenState extends State<MyCameraScreen> {
PickedFile imageURI;
final ImagePicker _picker=ImagePicker();

Future getImageFromGallery(bool isCamera) async{
  var image=await _picker.getImage(source:(isCamera==true)?ImageSource.camera:ImageSource.gallery);
  setState((){
    imageURI=image;
  });
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kGreen,
        title: Text('SillyCam'),
      ),
      body: SingleChildScrollView(
        child:Column(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                      child: imageURI==null?Image.network("https://media1.tenor.com/images/78d21171ff21c08eb6b19a56b09d37a4/tenor.gif?itemid=14148230",height: 400,width:500,): Image.file(File(imageURI.path)),
                    ),
                Container(
                  width: MediaQuery.of(context).size.width,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.end,

                    children: <Widget>[
                      FloatingActionButton(
                        heroTag: null,
                        onPressed: (){
                          getImageFromGallery(false);
                        },
                        child: Icon(
                          Icons.photo_album,
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      FloatingActionButton(
                        heroTag: null,
                        onPressed: (){
                          uploadImageToServer(File(imageURI.path));
                        },
                        child: Icon(
                          Icons.file_upload,
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                    ],
                  ),
                ),
                Stack(
                  fit: StackFit.loose,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 40.0),
                      child: Container(
                        height: 1,
                        width: MediaQuery.of(context).size.width,
                        color: Colors.grey,
                      ),
                    ),
                    Center(
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle, color: Colors.white),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 10.0),
                      child: Center(
                        child: Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                              border: Border.all(color: Colors.grey, width: 2)),
                          child: IconButton(
                            onPressed: (){
                              getImageFromGallery(true);
                            },
                            icon: Icon(Icons.camera_alt),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        )
      ),
    );
  }
uploadImageToServer(File imageFile)async
{
  String rootURI = 'https://816bdebeabcf.ngrok.io/';
  http.MultipartRequest request = http.MultipartRequest('POST', Uri.parse('$rootURI/api'));
  request.files.add(
    await http.MultipartFile.fromPath(
      'image',
      imageFile.path,
      contentType: MediaType('application', 'png'),
    ),
  );
  http.StreamedResponse r = await request.send();
  String rstring = (await r.stream.transform(utf8.decoder).join());
  Map<String, dynamic> rjson = jsonDecode(rstring);
  String imageUrl = rjson["file_url"];
  Navigator.push(context, MaterialPageRoute(builder: (context)=> Profile('$rootURI$imageUrl')));
}

}
