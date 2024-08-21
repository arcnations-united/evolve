//A new file to handle css files freshly in a new way
import 'dart:io';

class CSS{
  late File cssFile;
  late String cssContents;
  late List <String> namedParts=[];
  late List <int> editedIndices=[];
  late String themeName;
   CSS(String f,){
    cssFile=File(f);
    themeName=cssFile.parent.parent.path.split("/").last;
  }
  fetchCSS() async{
    cssContents=await cssFile.readAsString();
    int showIndex=4;
    getNamedParts(showIndex);
  }
  void getNamedParts(int showIndex) {
    int startInd=0;
    int lastInd=1;
    namedParts.clear();
    for(;;){
      if(startInd==-1||lastInd==-1)break;
      startInd = cssContents.indexOf("/*", lastInd);
      if(startInd==-1||lastInd==-1)break;
      lastInd = cssContents.indexOf("*/", startInd);
      String cnt =(cssContents.substring(startInd, lastInd));
     if(cnt.replaceAll("/", '').replaceAll("*", "").replaceAll('\n', '').trim().split(" ").length<=showIndex)namedParts.add(cnt.replaceAll("/*", "").trim());
    }
  }
  String fetchNamedPortion(int index){
    String src=namedParts[index];
    int start = cssContents.indexOf(src)+src.length;
    start=cssContents.indexOf("\n", start)+1;
    int end= cssContents.indexOf("/*",start)-1;
    if(end==-2)end=cssContents.length;
    return cssContents.substring(start,end).replaceAll("*", '');
  }
  int getNamedIndex(String name){
    List l = List.generate(namedParts.length, (index) => namedParts[index].toLowerCase());
    return l.indexOf(name.toLowerCase());
  }
  replaceNamedPortion({required int index, int? otherIndex, required CSS otherCSS}){
    otherIndex ??= otherCSS.getNamedIndex(namedParts[index]);
    cssContents=cssContents.replaceAll(fetchNamedPortion(index), otherCSS.fetchNamedPortion(otherIndex));
    editedIndices.add(index);
  }
  saveCSS() async {
     await cssFile.writeAsString(cssContents);
     editedIndices.clear();
     cssContents="";
     namedParts.clear();
     await fetchCSS();
  }

  }