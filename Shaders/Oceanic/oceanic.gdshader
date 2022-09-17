shader_type spatial;

#define RENDER_GODRAYS    1    // set this to 1 to enable god-rays
//#define RENDER_GODRAYS    0    // disable god-rays

#define RENDER_CLOUDS 1
#define RENDER_WATER   1
#define NUM_OCTAVES 5

const float waterlevel = 70.0;        // height of the water
const float wavegain   = 1.0;       // change to adjust the general water wave level
const float large_waveheight = 1.0; // change to adjust the "heavy" waves (set to 0.0 to have a very still ocean :)
const float small_waveheight = 1.0; // change to adjust the small waves

const vec3 fogcolor    = vec3( 0.5, 0.7, 1.1 );              
const vec3 skybottom   = vec3( 0.6, 0.8, 1.2 );
const vec3 skytop      = vec3(0.05, 0.2, 0.5);
const vec3 reflskycolor= vec3(0.025, 0.10, 0.20);
const vec3 watercolor  = vec3(0.2, 0.25, 0.3);

const vec3 light       = normalize( vec3(  0.1, 0.25,  0.9 ) );
             
float hash( float n )
{
	return fract(cos(n)*41415.92653);
}

//float noise(vec2 p)
//{
//	return 0.0;
//	//return textureLod(TEXTURE,p*vec2(1./256.),0.0).x;
//}

// 3d noise function
//float mod289(float x){return x - floor(x * (1.0 / 289.0)) * 289.0;}
vec4 mod289(vec4 x){return x - floor(x * (1.0 / 289.0)) * 289.0;}
vec4 perm(vec4 x){return mod289(((x * 34.0) + 1.0) * x);}

float noise(vec3 p){
    vec3 a = floor(p);
    vec3 d = p - a;
    d = d * d * (3.0 - 2.0 * d);
	
    vec4 b = a.xxyy + vec4(0.0, 1.0, 0.0, 1.0);
    vec4 k1 = perm(b.xyxy);
    vec4 k2 = perm(k1.xyxy + b.zzww);

    vec4 c = k2 + a.zzzz;
    vec4 k3 = perm(c);
    vec4 k4 = perm(c + 1.0);

    vec4 o1 = fract(k3 * (1.0 / 41.0));
    vec4 o2 = fract(k4 * (1.0 / 41.0));

    vec4 o3 = o2 * d.z + o1 * (1.0 - d.z);
    vec2 o4 = o3.yw * d.x + o3.xz * (1.0 - d.x);

    return o4.y * d.y + o4.x * (1.0 - d.y);
}

float rand(vec2 n) { 
	return fract(sin(dot(n, vec2(12.9898, 4.1414))) * 43758.5453);
}

float noise2D(vec2 p)
{
	vec2 ip = floor(p);
	vec2 u = fract(p);
	u = u*u*(3.0-2.0*u);
	
	float res = mix(
		mix(rand(ip),rand(ip+vec2(1.0,0.0)),u.x),
		mix(rand(ip+vec2(0.0,1.0)),rand(ip+vec2(1.0,1.0)),u.x),u.y);
	return res*res;
}

const mat3 m = mat3( 
	vec3(0.00,  1.60,  1.20), 
	vec3(-1.60,  0.72, -0.96), 
	vec3(-1.20, -0.96,  1.28)
);

// Fractional Brownian motion
float fbm(vec3 p )
{
  float f = 0.5000*noise( p ); p = m*p*1.1;
  f += 0.2500*noise( p ); p = m*p*1.2;
  f += 0.1666*noise( p ); p = m*p;
  f += 0.0834*noise( p );
  return f;
}

float fbm2D(vec2 x)
{
	float v = 0.0;
	float a = 0.5;
	vec2 shift = vec2(100);
	
	// Rotate to reduce axial bias
    mat2 rot = mat2(
		vec2(cos(0.5), sin(0.5)), 
		vec2(-sin(0.5), cos(0.50))
	);
	
	for (int i = 0; i < NUM_OCTAVES; ++i) {
		v += a * noise2D(x);
		x = rot * x * 2.0 + shift;
		a *= 0.5;
	}
	return v;
}

const mat2 m2 = mat2(
	vec2(1.6,-1.2),
	vec2(1.2,1.6)
);

// this calculates the water as a height of a given position
float water( vec2 p )
{
  float height = waterlevel;

  vec2 shift1 = 0.001*vec2( TIME*160.0*2.0, TIME*120.0*2.0 );
  vec2 shift2 = 0.001*vec2( TIME*190.0*2.0, -TIME*130.0*2.0 );

  // coarse crossing 'ocean' waves...
  float wave = 0.0;
  wave += sin(p.x*0.021  + shift2.x)*4.5;
  wave += sin(p.x*0.0172+p.y*0.010 + shift2.x*1.121)*4.0;
  wave -= sin(p.x*0.00104+p.y*0.005 + shift2.x*0.121)*4.0;
  // ...added by some smaller faster waves...
  wave += sin(p.x*0.02221+p.y*0.01233+shift2.x*3.437)*5.0;
  wave += sin(p.x*0.03112+p.y*0.01122+shift2.x*4.269)*2.5 ;
  wave *= large_waveheight;
  wave -= fbm2D(p * 0.004 -shift2 * 0.5) * small_waveheight * 24.0;
  // ...added by some distored random waves (which makes the water looks like water :)

  float amp = 6.*small_waveheight;
  shift1 *= 0.3;
  for (int i=0; i<7; i++)
  {
    wave -= abs(sin((noise2D(p*0.01+shift1)-0.5)*3.14))*amp;
    amp *= 0.51;
    shift1 *= 1.841;
    p *= m2*0.9331;
  }
  
  height += wave;
  return height;
}


// cloud intersection raycasting
float trace_fog(in vec3 rStart, in vec3 rDirection )
{
#if RENDER_CLOUDS
  // makes the clouds moving...
  vec2 shift = vec2( TIME*80.0, TIME*60.0 );
  float sum = 0.0;
  // use only 12 cloud-layers ;)
  // this improves performance but results in "god-rays shining through clouds" effect (sometimes)...
  float q2 = 0., q3 = 0.;
  for (int q=0; q<10; q++)
  {
    float c = (q2+350.0-rStart.y) / rDirection.y;// cloud distance
    vec3 cpos = rStart + c*rDirection + vec3(831.0, 321.0+q3-shift.x*0.2, 1330.0+shift.y*3.0); // cloud position
    float alpha = smoothstep(0.5, 1.0, fbm( cpos*0.0015 )); // cloud density
	sum += (1.0-sum)*alpha; // alpha saturation
    if (sum>0.98)
        break;
    q2 += 120.;
    q3 += 0.15;
  }
  
  return clamp( 1.0-sum, 0.0, 1.0 );
#else
  return 1.0;
#endif
}

// fog and water intersection function.
// 1st: collects fog intensity while traveling
// 2nd: check if hits the water surface and returns the distance
bool trace(in vec3 rStart, in vec3 rDirection, in float sundot, out float fog, out float dist)
{
  float h = 20.0;
  float t = 0.0;
  float st = 1.0;
  float alpha = 0.1;
  float asum = 0.0;
  vec3 p = rStart;
	
  for( int j=1000; j<1120; j++ )
  {
    // some speed-up if all is far away...
    if( t>500.0 ) 
      st = 2.0;
    else if( t>800.0 ) 
      st = 5.0;
    else if( t>1000.0 ) 
      st = 12.0;

    p = rStart + t*rDirection; // calc current ray position

#if RENDER_GODRAYS
    if (rDirection.y>0. && sundot > 0.001 && t>400.0 && t < 2500.0)
    {
      alpha = sundot * clamp((p.y-waterlevel)/waterlevel, 0.0, 1.0) * st * 0.024*smoothstep(0.80, 1.0, trace_fog(p,light));
      asum  += (1.0-asum)*alpha;
      if (asum > 0.9)
        break;
    }
#endif

    h = p.y - water(p.xz);

    if( h<0.1 ) // hit the water?
    {
      dist = t; 
      fog = asum;
      return true;
    }

    if( p.y>450.0 ) // lost in space? quit...
      break;
    
    // speed up ray if possible...    
    if(rDirection.y > 0.0) // look up (sky!) -> make large steps
      t += 30.0 * st;
    else
      t += max(1.0,1.0*h)*st;
  }

  dist = t; 
  fog = asum;
  if (h<10.0)
   return true;
  return false;
}


vec3 camera( float time )
{
  return vec3( 500.0 * sin(1.5+1.57*time), 0.0, 1200.0*time );
}


void fragment(){
  vec2 xy = -1.0 + 2.0*FRAGCOORD.xy / (1.0/VIEWPORT_SIZE).xy;
  vec2 s = xy*vec2(1.75,1.0);

  // get camera position and view direction
  float time = (TIME+13.5+44.)*.05;
  vec3 campos = camera( time );
  vec3 camtar = camera( time + 0.4 );
  campos.y = max(waterlevel+30.0, waterlevel+90.0 + 60.0*sin(time*2.0));
  camtar.y = campos.y*0.5;

  float roll = 0.14*sin(time*1.2);
  vec3 cw = normalize(camtar-campos);
  vec3 cp = vec3(sin(roll), cos(roll),0.0);
  vec3 cu = normalize(cross(cw,cp));
  vec3 cv = normalize(cross(cu,cw));
  vec3 rd = normalize( s.x*cu + s.y*cv + 1.6*cw );

  float sundot = clamp(dot(rd,light),0.0,1.0);

  vec3 col;
  float fog=0.0, dist=0.0;

  if (!trace(campos,rd,sundot, fog, dist))
  {
    // render sky
    float t = pow(1.0-0.7*rd.y, 15.0);
    col = 0.8*(skybottom*t + skytop*(1.0-t));
    // sun
    col += 0.47*vec3(1.6,1.4,1.0)*pow( sundot, 350.0 );
    // sun haze
    col += 0.4*vec3(0.8,0.9,1.0)*pow( sundot, 2.0 );

#if RENDER_CLOUDS
    // CLOUDS
    vec2 shift = vec2( TIME*80.0, TIME*60.0 );
    vec4 sum = vec4(0,0,0,0); 
    for (int q=1000; q<1100; q++) // 100 layers
    {
      float c = (float(q-1000)*12.0+350.0-campos.y) / rd.y; // cloud height
      vec3 cpos = campos + c*rd + vec3(831.0, 321.0+float(q-1000)*.15-shift.x*0.2, 1330.0+shift.y*3.0); // cloud position
      float alpha = smoothstep(0.5, 1.0, fbm( cpos*0.0015 ))*.9; // fractal cloud density
      vec3 localcolor = mix(vec3( 1.1, 1.05, 1.0 ), 0.7*vec3( 0.4,0.4,0.3 ), alpha); // density color white->gray
      alpha = (1.0-sum.w)*alpha; // alpha/density saturation (the more a cloud layer's density, the more the higher layers will be hidden)
      sum += vec4(localcolor*alpha, alpha); // sum up weightened color
      
      if (sum.w>0.98)
        break;
    }
    float alpha = smoothstep(0.7, 1.0, sum.w);
    sum.rgb /= sum.w+0.0001;

    // This is an important stuff to darken dense-cloud parts when in front (or near)
    // of the sun (simulates cloud-self shadow)
    sum.rgb -= 0.6*vec3(0.8, 0.75, 0.7)*pow(sundot,13.0)*alpha;
    // This brightens up the low-density parts (edges) of the clouds (simulates light scattering in fog)
    sum.rgb += 0.2*vec3(1.3, 1.2, 1.0)* pow(sundot,5.0)*(1.0-alpha);

    col = mix( col, sum.rgb , sum.w*(1.0-t) );
#endif

    // add god-rays
    col += vec3(0.5, 0.4, 0.3)*fog;
  }
  else
  {
#if RENDER_WATER        
    //  render water
    
    vec3 wpos = campos + dist*rd; // calculate position where ray meets water

    // calculate water-mirror
    vec2 xdiff = vec2(0.1, 0.0)*wavegain*4.;
    vec2 ydiff = vec2(0.0, 0.1)*wavegain*4.;

    // get the reflected ray direction
    rd = reflect(rd, normalize(vec3(water(wpos.xz-xdiff) - water(wpos.xz+xdiff), 1.0, water(wpos.xz-ydiff) - water(wpos.xz+ydiff))));  
    float refl = 1.0-clamp(dot(rd,vec3(0.0, 1.0, 0.0)),0.0,1.0);
  
    float sh = smoothstep(0.2, 1.0, trace_fog(wpos+20.0*rd,rd))*.7+.3;
    // water reflects more the lower the reflecting angle is...
    float wsky   = refl*sh;     // reflecting (sky-color) amount
    float wwater = (1.0-refl)*sh; // water-color amount

    float sundot = clamp(dot(rd,light),0.0,1.0);

    // watercolor

    col = wsky*reflskycolor; // reflecting sky-color 
    col += wwater*watercolor;
    col += vec3(.003, .005, .005) * (wpos.y-waterlevel+30.);

    // Sun
    float wsunrefl = wsky*(0.5*pow( sundot, 10.0 )+0.25*pow( sundot, 3.5)+.75*pow( sundot, 300.0));
    col += vec3(1.5,1.3,1.0)*wsunrefl; // sun reflection

#endif

    // global depth-fog
    float fo = 1.0-exp(-pow(0.0003*dist, 1.5));
    vec3 fco = fogcolor + 0.6*vec3(0.6,0.5,0.4)*pow( sundot, 4.0 );
    col = mix( col, fco, fo );

    // add god-rays
    col += vec3(0.5, 0.4, 0.3)*fog; 
  }

  ALBEDO=vec4(col,1.0);
}


