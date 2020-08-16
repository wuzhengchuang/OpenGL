precision highp float;
uniform sampler2D colorMap;
uniform vec2 TexSize;
const vec2 MosaicSize = vec2(24.0,24.0);
varying vec2 varyTextCoord;
void main(void){
    vec2 intXY = vec2(varyTextCoord.x*TexSize.x,varyTextCoord.y*TexSize.y);
    vec2 XYMosaic = vec2(floor(intXY.x/MosaicSize.x)*MosaicSize.x,floor(intXY.y/MosaicSize.y)*MosaicSize.y);
    vec2 UVMosaic = vec2(XYMosaic.x/TexSize.x,XYMosaic.y/TexSize.y);
    vec4 mask = texture2D(colorMap,UVMosaic);
    gl_FragColor = vec4(mask);
}

