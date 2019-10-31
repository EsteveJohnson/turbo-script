function CommandWaifu2x(clip c)
{
    Space=" "
    DirectoryProgram=""" "C:\avsWaifu\waifu2x-converter\" """
    NameProgram="waifu2x-converter-cpp.exe"
    PImageInOut = "-i" + Space + "'" +  GInputImage + "'" + Space + "-o" + Space + "'" + GOuputImage + "'" + Space
    Parameters ="-m noise-scale -v 1 --noise-level" + Space + string(GNoise) + Space + "--scale-ratio" + Space + string(GScale)
    #~ FOR PROGRAM waifu2x-ncnn-vulkan 
    #~ Parameters ="-t 256 -n" + Space + string(GNoise) + Space + "-s" + Space + string(GScale)
    #~ FOR PROGRAM waifu2x-caffe-cui.exe
    #~ Parameters ="-b 1 -c 128 -p cudnn -n" + Space + string(GNoise) + Space + "-s" + Space + string(GScale)
    Global LineCommand= DirectoryProgram + Space + NameProgram + Space + Parameters + Space + PImageInOut
    ScriptClip(c,"""Call( "cmd /C title Frame:" + string(current_frame)+ "/" + string(last.FrameCount) + " & start /wait /B /D " + LineCommand, string(current_frame))""",after_frame = True)
    return last
    #~ Global Command=GDirectoryWork + "CommandWaifu.bat"
    #~ ScriptClip(c,"""Call( Command+" "+string(current_frame)+"/"+string(last.FrameCount)+" "+ string(GNoise) + " " + string(GScale) + " " + GDirectoryWork, string(current_frame))""",after_frame = True)
}

function ResizeColorSpace(clip c,int "Width",int "Height")
{
    #~Necessary for check frames duplicated YV12 YDifferenceFromPrevious
    BilinearResize(c,GNewWidth,GNewHeight).ConvertToYV12()
    return last
}

function videoWaifu2X(clip clipvideo,int "NewWidth",int "NewHeight",int "Noise",int "Scale",float "thresholdDuplicate",string "DirectoryTemp",string "TempName")
{
    Global GDirectoryWork=default(DirectoryTemp, "C:\avsWaifu\")
    Global GthresholdDuplicate=default(thresholdDuplicate,0.001)
    Global GNoise=default(Noise,2)
    Global GScale=default(Scale,2)
    Global GNewWidth=default(NewWidth,clipvideo.Width*GScale)
    Global GNewHeight=default(NewHeight,clipvideo.Height*GScale)

    TempName=default(TempName,"Wtmp")
    Global GInputImage=GDirectoryWork + TempName + ".bmp"
    Global GOuputImage=GDirectoryWork + TempName + ".png"
    
    clipvideo.ConvertToRGB24()
    ScriptClip("""ImageWriter(GInputImage+"%n%s",start =current_frame, end =current_frame)""",after_frame = true).ResizeColorSpace()
    ConditionalSelect("current_frame!=0 && YDifferenceFromPrevious<GthresholdDuplicate?0:1", last ,CommandWaifu2x())
    ScriptClip("""ImageSourceAnim(GOuputImage).ResizeColorSpace()""",after_frame =true)

}
