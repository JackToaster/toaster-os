shader_type canvas_item;
render_mode unshaded;

uniform sampler2D noise;
uniform sampler2D bb;

const vec2 iResolution = vec2(64,32);

#define _Size 0.3 //size of BH
#define DISK_START 0.7
#define DISK_END 2.0


#define iterations 13
#define formuparam 0.53

#define volsteps 20
#define stepsize 0.1

#define tile   0.850
#define speed  0.010

#define brightness 0.004
#define darkmatter 0.300
#define distfading 0.730
#define saturation 0.850

// From https://www.shadertoy.com/view/XdsGDB
// Set up a camera looking at the scene.
void CamPolar( out vec3 pos, out vec3 ray, in vec3 origin, in vec2 rotation, in float distance, in float zoom, in vec2 fragCoord )
{
	// get rotation coefficients
	vec2 c = vec2(cos(rotation.x),cos(rotation.y));
	vec4 s;
	s.xy = vec2(sin(rotation.x),sin(rotation.y)); // worth testing if this is faster as sin or sqrt(1.0-cos);
	s.zw = -s.xy;

	// ray in view space
	ray.xy = fragCoord.xy - iResolution.xy*.5;
	ray.z = iResolution.y*zoom;
	ray = normalize(ray);

	// rotate ray
	ray.yz = ray.yz*c.xx + ray.zy*s.zx;
	ray.xz = ray.xz*c.yy + ray.zx*s.yw;

	// position camera
	pos = origin - distance*vec3(c.x*s.y,s.z,c.x*c.y);
}

// todo blackbody doesn't work here???
vec3 blackbody( float t )
{
    return texture(bb, vec2(t / 3000.0, 0.)).rgb;
}

vec3 disk(vec3 ro, vec3 rd, float itime) {
    float height = ro.y;
    float vv = rd.y;
    vec3 hp = ro - (rd * (ro.y / rd.y));
    float dist = length(hp);

    float inner_temp = 3000.0;
    float outer_temp = 000.0;

    float disk_dist = (dist - DISK_START) / (DISK_END - DISK_START);

    float disk_a = smoothstep(0., 0.1, disk_dist) - smoothstep(0.9, 1., disk_dist);

    float temp = mix(inner_temp, outer_temp, disk_dist);

    float ang = atan(hp.x,hp.z) + 3. * itime;
    temp += texture(noise, vec2(fract(disk_dist * 2.5), fract(1. * ang / PI))).r * 700.0;
    //vec3 rd_col = hp.xyz * vec3(0.5) + vec3(0.5);

    return blackbody(temp) * disk_a;
}


vec3 starnest(in vec3 from, in vec3 dir) {
    float s=0.1,fade=1.;
	vec3 v=vec3(0.);
	for (int r=0; r<volsteps; r++) {
		vec3 p=from+s*dir*.5;
		p = abs(vec3(tile)-mod(p,vec3(tile*2.))); // tiling fold
		float pa,a=pa=0.;
		for (int i=0; i<iterations; i++) {
			p=abs(p)/dot(p,p)-formuparam; // the magic formula
			a+=abs(length(p)-pa); // absolute sum of average change
			pa=length(p);
		}
		float dm=max(0.,darkmatter-a*a*.001); //dark matter
		a*=a*a; // add contrast
		if (r>6) fade*=1.-dm; // dark matter, don't render near
		//v+=vec3(dm,dm*.5,0.);
		v+=fade;
		v+=vec3(s,s*s,s*s*s*s)*a*brightness*fade; // coloring based on distance
		fade*=distfading; // distance fading
		s+=stepsize;
	}
	v=mix(vec3(length(v)),v,saturation); //color adjust

	return v * 0.02 - 0.5;
}


void vertex() {

}

void fragment() {
	// Called for every pixel the material is visible on.
	COLOR = vec4(0.,0.,0.,1.);
	vec3 ro, rd;

    vec3 cam_origin = vec3(0.);

    vec2 camRot = vec2(-0.2 + 0.2 * cos(TIME * 0.3), 0.9 + 0.3 * sin(TIME * 0.5));

    CamPolar(ro, rd,
        cam_origin, // Origin
        camRot, // Rotation
        3., // Distance
        0.8, //Zoom
        UV * iResolution + vec2(10.,5.));


    vec3 pos = ro;
    vec3 ray = rd;
    int nsteps = 0;
    for(int disks = 0; disks< 128; disks++) //steps
    {
        float dotpos = dot(pos,pos);
        float invDist = inversesqrt(dotpos); //1/distance to BH
        float centDist = dotpos * invDist; 	//distance to BH
        float farLimit = centDist * 0.5; //limit step size far from to BH
        float closeLimit = centDist*0.1 + 0.05*centDist*centDist*(1./_Size); //limit step size closse to BH
        float stepDist = min(farLimit, closeLimit);

        float invDistSqr = invDist * invDist;
        float bendForce = stepDist * invDistSqr * _Size * 1.;  //bending force
        ray =  normalize(ray - (bendForce * invDist )*pos);  //bend ray towards BH

        vec3 stepVec = stepDist * ray;

        if(stepVec.y / pos.y < -1.) {
            vec3 diskCol = disk(pos, stepVec, TIME);
            COLOR.rgb += diskCol;
			//break;
        }

        pos += stepVec;

        nsteps += 1;
        float dist2 = length(pos);

        if(dist2 < _Size) //ray sucked in to BH
        {
			break;
        }

        else if(dist2 > _Size * 1000.) //ray escaped BH
        {
            vec3 bg = starnest (vec3(20.54567, 41.234,-13.4235), ray);
            COLOR.rgb += bg;
            break;
        }
    }
	//vec3 bg = starnest (vec3(20.54567, 41.234,-13.4235), ray);
    //COLOR.rgb = bg;

    //COLOR = vec4(0., 1., 0., 1.);
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
