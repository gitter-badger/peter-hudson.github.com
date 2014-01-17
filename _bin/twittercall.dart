import 'dart:io';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:utf/utf.dart';


void main(){
  var twitterCall = new Callings();  
}


class Callings {
  
  final String config_file = 'config.json';
  final String data_file = 'updates.json';
  final String calltype = 'https';
  final String hostname = 'api.twitter.com';
  final String api_v = '1.1';
  final String user_agent = 'My Twitter App v0.0.1';
  String start_id;   
  Map jsondata;
  
  Callings(){
    Loadconfig(GetUpdate);
  }
  
    
  void Loadconfig(pasd_action){
    File configfile = new File(config_file);
    configfile.readAsString(encoding: UTF8).then((filedata){
      jsondata = JSON.decode(filedata);
        start_id = jsondata['start_id'];
        pasd_action();
    });
  }
    
  
  void Auth(){
    var Uri_Map = new Uri(scheme: calltype, host: hostname, path: '/oauth2/token');     
    var coded_key_secret = CryptoUtils.bytesToBase64(encodeUtf8('${jsondata["consumer_key"]}:${jsondata["consumer_secret"]}'));
    List post_headers = [
                         ['User-Agent',user_agent],
                         ['Authorization','Basic $coded_key_secret'],
                         ['Content-Type','application/x-www-form-urlencoded;charset=UTF-8']
                        ];
    
    List post_body = ['grant_type=client_credentials'];    
    
    _OAuthCall(Uri_Map,post_headers,post_body);
  }
  
  
  void GetUpdate(){       
    String path_extra = '';
    if(start_id != "0"){
      path_extra = '&since_id=$start_id';
    }
    var Uri_Map = new Uri(scheme: calltype, host: hostname, path: '/$api_v/statuses/user_timeline.json?count=${jsondata["max_count"]}&screen_name=${jsondata["screen_name"]}$path_extra');   
    List post_headers = [
                         ['User-Agent',user_agent],
                         ['Authorization', 'Bearer ${jsondata["bearer"]}']                         
                        ]; 
    
    List post_body = [];

    _OAuthCall(Uri_Map,post_headers,post_body,'get');    
  }
  
  
  void _OAuthCall(Uri PassedUri, List PassedHeader, List PassedBody,[calltype = 'post']){   
    var rtn = false;
    var httpClient = new HttpClient();
    if(calltype == 'post'){
      calltype = httpClient.postUrl;
    }else{
      calltype = httpClient.getUrl;
    }
    
    calltype(PassedUri).then((HttpClientRequest request) {
      for(var header_line in PassedHeader){
        if(header_line.length == 2){
          request.headers.add(header_line[0], header_line[1]);
        }
      }
      request.headers.set(HttpHeaders.ACCEPT_ENCODING, "");
            
      for(var body_line in PassedBody){        
          request.write(body_line);
      }
      return request.close();
    }).then((HttpClientResponse response) {
      switch(response.statusCode){
        case 200:
        case 401:
        case 400:
          response.transform(UTF8.decoder).toList().then((data) {
          var json_data = JSON.decode(data.join(''));
          if(json_data is Map && json_data.containsKey('errors')){
            if(json_data['errors'][0].containsKey('code') && (json_data['errors'][0]['code'] == 89 || json_data['errors'][0]['code'] == 215)){
              Auth();
            }else{
              throw 'An unknown Twitter Error has occurred: $json_data';
            }
          }else{
            _DealWithResult(json_data,response.statusCode);
          }
          httpClient.close();
        });
        break;
        default:
          throw 'An error has occurred whilst trying to connect to Twitter.';
        break;          
      }
           
      
    });
    
  }
    
  
  void _DealWithResult(pasd_jsondata,header_response){
    if(pasd_jsondata is Map && pasd_jsondata.containsKey('access_token')){
      jsondata['bearer'] = pasd_jsondata['access_token'];
      _WriteToConfigFile();
      GetUpdate();
    }else{
      if(pasd_jsondata is List && pasd_jsondata.length > 0 && pasd_jsondata[0] is Map && pasd_jsondata[0].containsKey('id_str')){
        start_id = pasd_jsondata[0]['id_str'];
        jsondata['start_id'] = start_id;
        _WriteToConfigFile();
        _WriteToUpdatesFile(pasd_jsondata);
      }else if(pasd_jsondata is List && pasd_jsondata.length == 0 && header_response == 200){
        print('No updates have occurred');
      }else{
        throw 'An unknown error has occurred: Not the expected result from Twitter';
      }
      
    }
  }
  
  
  void _WriteToConfigFile(){
       _WriteToFile(config_file,jsondata);
  }
  
  
  void _WriteToUpdatesFile(pasd_jsondata){
      _ReadWriteFile(pasd_jsondata);
  }
  
  
  void _ReadWriteFile(pasd_jsondata){
    File tempFile = new File(data_file);
    tempFile.readAsString(encoding: UTF8).then((filedata){
      var temp_json;      
      if(filedata.length <= 0){
        filedata = '[]'; 
      }
      temp_json = JSON.decode(filedata);
      pasd_jsondata.addAll(temp_json);
      _WriteToFile(data_file,pasd_jsondata);
    });
  }
  
  
  void _WriteToFile(String filename, Object pasd_jsondata){
    var tmp_file = new File(filename).openWrite(mode:FileMode.WRITE, encoding: UTF8)
        ..write(JSON.encode(pasd_jsondata))
        ..close();
  }
  
}



