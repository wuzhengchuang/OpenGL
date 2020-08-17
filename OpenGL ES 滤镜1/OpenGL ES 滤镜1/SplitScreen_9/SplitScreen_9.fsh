precision highp float;
uniform sampler2D colorMap;
varying vec2 varyTextCoord;
void main(void){
    vec2 uv = varyTextCoord.xy;
    float x=uv.x,y=uv.y;
    if (uv.x>=0.0&&uv.x<0.3333) {
        x=uv.x*3.0;
    }else if (uv.x>=0.3333&&uv.x<0.6666) {
        x=(uv.x-0.3333)*3.0;
    }else{
        x=(uv.x-0.6666)*3.0;
    }
    if (uv.y>=0.0&&uv.y<0.3333) {
        y=uv.y*3.0;
    }else if (uv.y>=0.3333&&uv.y<0.6666) {
        y=(uv.y-0.3333)*3.0;
    }else{
        y=(uv.y-0.6666)*3.0;
    }
    gl_FragColor = texture2D(colorMap,vec2(x,y));
}
