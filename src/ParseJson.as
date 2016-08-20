/**
 * Created by zhouzhanglin on 16/8/19.
 */
package {
import flash.geom.Matrix;
import flash.geom.Point;
import flash.utils.Dictionary;

import utils.MD5;

public class ParseJson {
    public function ParseJson() {
    }

    private var _textureData:String;//spine的材质数据
    private var _spineData:Object;//spine数据对象，最终会将这个对象生成json
    private var _armatureObj:Object;//dragonBone中的一个armature

    public function get spineData():Object{
        return _spineData;
    }
    public function get textureData():String{
        return _textureData;
    }

    /**
     * 解析材质json
     * @param json
     */
    public function parseTextureJosn(json:String):void
    {
        var jsonObject:Object = JSON.parse(json);
        var n:String= "\n";
        var tab:String="  ";
        _textureData = "";
        _textureData = _textureData.concat(jsonObject["imagePath"]+n);
        _textureData = _textureData.concat("size: 0,0"+n);
        _textureData = _textureData.concat("format: RGBA8888"+n);
        _textureData = _textureData.concat("filter: Linear,Linear"+n);
        _textureData = _textureData.concat("repeat: none"+n);
        var subTexture:Array = jsonObject["SubTexture"] as Array;
        var len :uint=subTexture.length;
        for(var i:uint=0;i<len;++i){
            var textureObj:Object = subTexture[i];
            _textureData = _textureData.concat(textureObj["name"]+n);
            _textureData = _textureData.concat(tab+"rotate: false"+n);
            _textureData = _textureData.concat(tab+"xy: "+textureObj["x"]+" ,"+textureObj["y"]+n);
            _textureData = _textureData.concat(tab+"size: "+textureObj["width"]+" ,"+textureObj["height"]+n);

            if(textureObj.hasOwnProperty("frameWidth"))
                _textureData = _textureData.concat(tab+"orig: "+textureObj["frameWidth"]+" ,"+textureObj["frameHeight"]+n);
            else
                _textureData = _textureData.concat(tab+"orig: "+textureObj["width"]+" ,"+textureObj["height"]+n);

            if(textureObj.hasOwnProperty("frameX"))
                _textureData = _textureData.concat(tab+"offset: "+textureObj["frameX"]+" ,"+textureObj["frameY"]+n);
            else
                _textureData = _textureData.concat(tab+"offset: 0,0"+n);

            _textureData = _textureData.concat(tab+"index: -1"+n);
        }
    }


    /**
     * 解析动画json
     * @param json
     */
    public function parseAnimJson(json:String):void
    {
        var jsonObject:Object = JSON.parse(json);

        _spineData = new Object();
        _spineData["skeleton"] = new Object();
        _spineData["skeleton"].spine="3.1.0";
        _spineData["skeleton"].hash = MD5.hash(json);

        if(jsonObject.hasOwnProperty("armature")){
            var armatures:Array = jsonObject["armature"] as Array;
            for(var i:int=0;i<armatures.length;++i){
                _armatureObj = armatures[i];
                parseBones();
                parseSlots();
                parseSkins();
                break;
            }
        }
    }

    private function parseBones():void{
        if(_armatureObj.hasOwnProperty("bone")) {
            var spine_bones:Array = [];
            _spineData["bones"] = spine_bones;

            var db_bones:Array = _armatureObj["bone"] as Array;
            var db_bones_len:uint = db_bones.length;
            for(var i:int=0;i<db_bones_len;++i){
                var spine_bone:Object = new Object();
                spine_bones.push(spine_bone);

                var db_bone:Object = db_bones[i];
                if(db_bone.hasOwnProperty("name")){ //骨骼名字
                    var boneName:String = db_bone["name"].toString();
                    spine_bone["name"] = boneName;
                }
                if(db_bone.hasOwnProperty("parent")){//骨骼的父骨骼
                    var parentBoneName:String = db_bone["parent"].toString();
                    spine_bone["parent"] = parentBoneName;
                }
                if(db_bone.hasOwnProperty("length")){//length
                    var length:Number = Number(db_bone["length"]);
                    if(length>0){
                        spine_bone["length"] = length;
                    }
                }
                if(db_bone.hasOwnProperty("transform")){ //transform
                    var transform:Object = db_bone["transform"];
                    if(transform.hasOwnProperty("x")) spine_bone["x"] = Number(transform["x"]);
                    if(transform.hasOwnProperty("y")) spine_bone["y"] = -Number(transform["x"]);
                    if(transform.hasOwnProperty("skX")) spine_bone["rotation"] = -Number(transform["skX"]);
                    if(transform.hasOwnProperty("scX")) spine_bone["scaleX"] = Number(transform["scX"]);
                    if(transform.hasOwnProperty("scY")) spine_bone["scaleY"] = Number(transform["scY"]);
                }
                if(db_bone.hasOwnProperty("inheritRotation")){
                    if(int(db_bone["inheritRotation"])==0){
                        spine_bone["inheritRotation"] = false;
                    }
                }
                if(db_bone.hasOwnProperty("inheritScale")){
                    if(int(db_bone["inheritScale"])==0){
                        spine_bone["inheritScale"] = false;
                    }
                }
            }
        }

    }

    private function parseSlots():void{
        if(_armatureObj.hasOwnProperty("slot")){
            var spine_slots:Array = [];
            _spineData["slots"] = spine_slots;

            var db_slots:Array = _armatureObj["slot"] as Array;
            var db_slots_len:uint = db_slots.length;
            for(var i:int = 0;i<db_slots_len;++i){
                var spine_slot:Object = new Object();
                spine_slots.push(spine_slot);

                var db_slot:Object = db_slots[i];
                if(db_slot.hasOwnProperty("name")){ //slot name
                    spine_slot["name"] = db_slot["name"].toString();
                    spine_slot["attachment"] = spine_slot["name"];
                }
                if(db_slot.hasOwnProperty("parent")){ //parent bone name
                    spine_slot["bone"] = db_slot["parent"].toString();
                }
                if(db_slot.hasOwnProperty("blendMode")){ //blendMode name
                    spine_slot["blendMode"] = db_slot["blendMode"].toString();
                }
                if(db_slot.hasOwnProperty("color")){ //color
                    var db_color:Object = db_slot["color"];
                    var color:Object = new Object();
                    if(db_color.hasOwnProperty("aM")) color.a = uint(Number(db_color["aM"])*2.55);
                    if(db_color.hasOwnProperty("rM")) color.r = uint(Number(db_color["rM"])*2.55);
                    if(db_color.hasOwnProperty("gM")) color.g = uint(Number(db_color["gM"])*2.55);
                    if(db_color.hasOwnProperty("bM")) color.b = uint(Number(db_color["bM"])*2.55);
                    spine_slot["color"]=toDec(color.r,color.g,color.b,color.a);
                }
            }
        }
    }

    private function parseSkins():void{
        if(_armatureObj.hasOwnProperty("skin")){
            var spine_skins:Object=new Object();
            _spineData["skins"] = spine_skins;

            var db_skins:Array = _armatureObj["skin"] as Array;
            var db_skins_len:uint = db_skins.length;
            for(var i:uint = 0;i<db_skins_len ; ++i){
                var db_skin:Object = db_skins[i];

                var spine_skin:Object = new Object();
                if(db_skin["name"].length==0){
                    spine_skins["skin"+i] = spine_skin;
                }else{
                    spine_skins[db_skin["name"]] = spine_skin;
                }

                if(db_skin.hasOwnProperty("slot")){
                    var db_slots:Array = db_skin["slot"] as Array;
                    var db_slots_len = db_slots.length;
                    for(var j:uint =0 ;j<db_slots_len;++j){
                        var db_slot:Object = db_slots[j];

                        var spine_slot:Object = new Object();
                        spine_skin[db_slot["name"]] = spine_slot;

                        if(db_slot.hasOwnProperty("display")){
                            var displays:Array = db_slot["display"] as Array;//此slot中的对象
                            var displays_len:uint = displays.length;
                            for(var z:uint=0;z<displays_len;++z){
                                var display:Object = displays[z];

                                var spine_display:Object = new Object();
                                spine_slot[display["name"]] = spine_display;
                                if(display.hasOwnProperty("type") && display["type"]!="image"){ //类型
                                    var type:String = "mesh";
                                    if(display["type"]=="mesh" && display.hasOwnProperty("weights")){
                                        type="weightedmesh";
                                    }
                                    spine_display["type"]=type;
                                }
                                if(display.hasOwnProperty("transform")){ //transform
                                    var transform:Object = display["transform"];
                                    if(transform.hasOwnProperty("x")) spine_display["x"] = Number(transform["x"]);
                                    if(transform.hasOwnProperty("y")) spine_display["y"] = -Number(transform["y"]);
                                    if(transform.hasOwnProperty("skX")) spine_display["rotation"] = -Number(transform["skX"]);
                                    if(transform.hasOwnProperty("scX")) spine_display["scaleX"] = Number(transform["scX"]);
                                    if(transform.hasOwnProperty("scY")) spine_display["scaleY"] = Number(transform["scY"]);
                                }
                                if(display.hasOwnProperty("edges")) spine_display["edges"] = display["edges"];
                                if(display.hasOwnProperty("uvs")) spine_display["uvs"] = display["uvs"];
                                if(display.hasOwnProperty("triangles")) {
                                    var triangles:Array = display["triangles"] as Array;
                                    spine_display["triangles"] = triangles;
                                    spine_display["hull"] = triangles.length/3;
                                }
                                if(display.hasOwnProperty("vertices"))
                                {
                                    var vertices:Array = display["vertices"] as Array;
                                    if(display.hasOwnProperty("weights")){
                                        var slotPoseArr :Array = display["slotPose"] as Array;
                                        var slotPose:Matrix = new Matrix(slotPoseArr[0],slotPoseArr[1],slotPoseArr[2],
                                                slotPoseArr[3],slotPoseArr[4],slotPoseArr[5]);

                                        var bonePoseArr:Array = display["bonePose"] as Array;
                                        var bonePoseKV:Dictionary = new Dictionary();
                                        for(var m:uint = 0;m<bonePoseArr.length;m+=7){
                                            var matrix:Matrix=new Matrix(bonePoseArr[m+1],bonePoseArr[m+2],bonePoseArr[m+3],
                                            bonePoseArr[m+4],bonePoseArr[m+5],bonePoseArr[m+6]);
                                            matrix.invert();
                                            bonePoseKV["BoneIndex"+bonePoseArr[m]] = matrix;
                                        }

                                        var vertices_len:uint = vertices.length;
                                        var db_weights:Array=display["weights"] as Array;
                                        var spine_vertices:Array = [];
                                        for(var k:uint = 0;k<vertices_len;k+=2){
                                            var p:Point = slotPose.transformPoint(new Point(vertices[k],vertices[k+1]));
                                            spine_vertices.push(p.x);//vertexX
                                            spine_vertices.push(-p.y);//vertexY

                                            var wIndex :uint = k/2*3;
                                            var bIndex:uint = uint(db_weights[wIndex+1]);
                                            spine_vertices.push(bIndex);//骨骼索引
                                            var spine_bone:Object = _spineData["bones"][bIndex];
                                            p = (bonePoseKV["BoneIndex"+bIndex] as Matrix).transformPoint(new Point(spine_bone.x,spine_bone.y));
                                            spine_vertices.push(p.x);//绑定的x
                                            spine_vertices.push(-p.y);//绑定的y
                                            spine_vertices.push(db_weights[wIndex+2]);//权重
                                        }
                                        spine_display["vertices"] = spine_vertices;
                                    }else{
                                        spine_display["vertices"] = vertices;
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    /**
     * 合并A，R，G，B颜色通道
     * @param      r  红色通道
     * @param      g  绿色通道
     * @param      b  蓝色通道
     * @param      a  透明度
     * @return
     */
    public static function toDec(r:uint, g:uint, b:uint, a:uint = 255):uint
    {
        var sa:uint = a << 24;
        var sr:uint = r << 16;
        var sg:uint = g << 8;
        return sa | sr | sg | b;
    }
}
}
