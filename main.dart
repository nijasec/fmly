
import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:fm_radio_player/channel.dart';
import 'package:http/http.dart' as http;
import 'package:wakelock/wakelock.dart';

final  player =AudioPlayer();
String _position='';
int curindex=0;

String nowplaying='';
String src='https://bcovlive-a.akamaihd.net/19b535b7499a4719a5c19e043063f5d9/ap-southeast-1/6034685947001/playlist.m3u8?nocache=322970';
void main() => runApp(const MyApp());
class MyApp extends StatefulWidget{
const MyApp({super.key});

  @override
	_MyAppState createState() => _MyAppState();
}

Future<List<dynamic>> fetchChannels() async {
  var result =
      await http.get(Uri.parse("https://raw.githubusercontent.com/nijasec/radios/main/library.json"));
  return jsonDecode(result.body);
}
late List<Channel> lchannels;
class _MyAppState extends State<MyApp> {
	   late bool pressed=false;
     
 // late  List<dynamic> response;
 Future<List<Channel>> channels=getChannels();
 
@override
void initState() {

  Wakelock.enable();
  
 player.onPlayerStateChanged.listen((event) {
  //   log(event.toString());
     if(event==PlayerState.playing){
      
 setState(() {
      pressed=true;
    });

     }
     else{
     // Wakelock.disable();
 setState(() {
      pressed=false;
    });
     }
   
    });
 player.onPositionChanged.listen((p) => setState(() => _position = p.toString()));
super.initState();
}

@override
  Widget build(BuildContext context) {
 
    return MaterialApp(
        title: "FMly",
        theme: ThemeData.dark(),
        home: DefaultTabController(
            length: 2,
            child: Scaffold(
//                appBar: AppBar(
//                  title: Text(title),
//                ),

                body: SafeArea(
                    
                    child: Column(
                      //:const Color.fromARGB(255, 96, 224, 171),
                      
                      children: <Widget>[
                    
                  const PreferredSize(
                    
                    preferredSize: Size.fromHeight(50.0),
                
                    
                    child: TabBar(
                      indicatorColor: Color.fromARGB(255, 78, 39, 141),
                     // labelColor: Color.fromARGB(255, 238, 237, 237),
                     // dividerColor: Color.fromARGB(255, 6, 26, 24),
                      
                      tabs: [
                        Tab(
                          text: 'Playlist',


                        //  tileColor:Color.fromARGB(2, 2, 5, 5)
                           
                        ),
                        Tab(
                          text: 'About',
                        ),
                       
                      ], // list of tabs
                    ),
                  ),
                  //TabBarView(children: [ImageList(),])
                  Expanded(
                    child: TabBarView(
                      children: [
                        Container(
                            color:Color.fromARGB(255, 14, 19, 17),
                          child: Center(child: 
                          FutureBuilder<List<Channel>>(
                            future: channels,
                            builder: (context,snapshot)
                            {
                              if (snapshot.connectionState==ConnectionState.waiting){
                                return const CircularProgressIndicator();
                              }else if(snapshot.hasError)
                              {
                                return Text('Oops! ${snapshot.error}');
                              }else if(snapshot.hasData){

                                     final chs=snapshot.data!;
                              
                                return buildChannels(chs);

                              }else
                              {
                                  return const Text('No channels available.');
                              }
                             
                            }
                          )
                            ,)
                          //buildChannels(channels),),//[Center(child: Text('Tab1'))],

                        ),
                        Container(
                          padding: const EdgeInsets.all(20),
                         // textColor:Color.fromARGB(1, 255, 3, 2),
                       
                          color:Color.fromARGB(255, 15, 20, 18),
                          child: const Column( children: [Text('FMly Player App.'),
                          Text('Listen to some random collection of FM Radio channels. '),
                          Text('Send your suggestions and feedback to techamgesolutions@gmail.com.'),
  Text('Contact developer via Telegram https://t.me/+quy6CHF53BhjNGI0')
                          
                          ]
                           ),
                        ),
                       // class name
                      ],
                    ),
                  ),

                  Container(
                   // color: const Color.fromARGB(255, 181, 218, 199),
                    padding:const  EdgeInsets.all(10),
                  //   height: MediaQuery.of(context).size.height / 6.2,
                    child:Column(children: [
                       Text(nowplaying),
Text(_position),

  Row( 
                      
                      mainAxisAlignment: MainAxisAlignment.center, children: [
IconButton(icon: const Icon(Icons.skip_previous),onPressed: (){

   if(curindex>0)
  {
    curindex--;
    src=lchannels[curindex].SURL;
    setState(() {
      nowplaying=lchannels[curindex].STATION_NAME;
    },);

    loadandplay();
}
  }
  ),                          
        IconButton(
        iconSize: 30.0,
        padding: const EdgeInsets.only(left: 4, right: 4, top: 0),
        icon: Padding(
            padding: const EdgeInsets.all(8.0),
            child: pressed == true ? const Icon(Icons.pause) : const Icon(Icons.play_arrow)),
        onPressed: () {
        //  print("pressed");
        if(!pressed)
        {
        //  player.play();
        loadandplay();
        }
        else {
          playerpause();
        }
        /*  setState(() {
            pressed = !pressed;
          });*/
        },
      ),
       

IconButton(icon: const Icon(Icons.skip_next),onPressed: (){   
  if(curindex<lchannels.length)
  {
    curindex++;
    src=lchannels[curindex].SURL;
    setState(() {
      nowplaying=lchannels[curindex].STATION_NAME;
    },);

    loadandplay();
  }

}), 
/*IconButton(icon: const Icon(Icons.volume_off_rounded),onPressed: (){})*/

],)  ,

                    ],) 
                    
                     // Also Including Tab-bar height.
//                        child: Chewie(
//                          controller: _chewieController,
//                        ),
                  ),  
                   
                   
Container(
  color:const Color.fromARGB(255, 13, 26, 20),
  padding: const EdgeInsets.all(10),
)
                ])))));
 
}
Widget buildChannels(List<Channel> channels)=>ListView.builder(
  itemCount: channels.length,
  
  itemBuilder: (context,index){
    final channel=channels[index];
    return Card(child: ListTile(autofocus: true,
   // textColor: Color.fromARGB(255, 235, 230, 230),
   leading: const Icon(Icons.radio_sharp),
    tileColor: (nowplaying==channel.STATION_NAME) ?const Color.fromARGB(255, 61, 8, 39):const Color.fromARGB(255, 7, 5, 7),
    onTap: ()=>{
      src=channel.SURL,
      loadandplay(),
      
      setState(() {
           // pressed = !pressed;
            nowplaying=channel.STATION_NAME.toString();
            curindex=index;
          })
   //   log("tapped"+channel.STATION_NAME)
   },
    title:  Text(channel.STATION_NAME)
   
    ),
    );
  });
}

 Future<List<Channel>> getChannels() async {

 const url='https://raw.githubusercontent.com/nijasec/radios/main/library.json';
 final response=await http.get(Uri.parse(url));
 final body=json.decode(response.body);
 lchannels=body.map<Channel>(Channel.fromJson).toList();
  return body.map<Channel>(Channel.fromJson).toList();

}
/*

 List<Channel> getChannels() {
const data=[
  {
    "ID":101,
    "STATION_NAME":"Radio Mango"
  },
  {
    "ID":102,
    "STATION_NAME":"Kadak FM"
  }
  ];
  return data.map<Channel>(Channel.fromJson).toList();


}
*/

void loadandplay() async {

try{
await player.play(UrlSource(src)); 
}catch(e){
log(e.toString());
}
      
     

}



void playerpause() {

  player.pause();
}

