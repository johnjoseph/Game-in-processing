// Global variables
float frmcnt=60,r=10,g,u,delay=10,x,y,grnd,t=0,y_gps,x_gps,theta,u_x,u_y,u_xx,u_yy,x_lower,x_upper;
float n=0,i,x_ell,y_inter,x_inter,c_line,m_line,gd,dsc,y_val,pre=-1,a_quad,b_quad,c_quad,x_shift=20,t_inter;
float[] a=new float[10],b=new float[10],c=new float[10],d=new float[10],y_inter_gps=new float[10],x_inter_gps=new float[10],angle=new float[10];
float u_val=80,g_val=10,theta_val=60,target_x=700,target_y=400,val_ang,x_ang,y_ang;
// Setup the Processing Canvas
interface JavaScript
{
  // we promise Processing that a function with this signature will exist in objects that we say are of this type
  void winner();
}

// sketch-global object that will point to the on-page javascript
JavaScript javascript = null;

// a method for binding the page's javascript environment to the in-sketch jsinterface object
void setJavaScript(JavaScript js) { javascript = js;}


void init(u_val,g_val,theta_val)
{
  u=u_val;
  g=g_val;
  theta=(3.14/180)*theta_val;
  u_xx=u;u_yy=u;
  period=2*u*sin(theta)/g;
  loop();      
}

void setup()
{
  size( window.innerWidth-230, window.innerHeight);
  stroke(100,100,100);  
  strokeWeight(0);
  frameRate(frmcnt);
  grnd=2*height/3;
  gd=grnd; // ground for reference
  u=u_val;
  g=g_val;
  theta=(3.14/180)*theta_val;
  u_xx=u;u_yy=u;
  period=2*u*sin(theta)/g;
  angle[-1]=0; 
  noLoop();
  a[-1]=0;
  b[-1]=grnd;
  c[-1]=width;
  d[-1]=grnd; 
}

// Main draw loop
void draw()
{
  background(255,255,255);
  //ground
  fill(233,233,233);
  rect(target_x,target_y,30,30);
  fill(100,100,100);
  text(val_ang,x_ang,y_ang);
  u_x=u_xx*cos(theta);
  u_y=u_yy*sin(theta);
  //motion
  t_corr=floor((t%period)*10)/10;
  y=(u_y*t_corr)-(.5*g*t_corr*t_corr); // eqn wrt ref grnd
  x=u_x*t_corr;
  fill(0,0,0);

  y_gps=gd-y; //wrt gps
  x_gps=x+x_shift; //wrt gps

  //collision with target
  if((x_gps>target_x)&&(x_gps<(target_x+30))&&(y_gps>target_y)&&(y_gps<(target_y+30)))
  {
    if(javascript!=null) { javascript.winner(); }
  }

  // collision with line  
  if((x_inter_gps[n-1])&&((n-1)!=pre)&&(floor(x_gps)==floor(x_inter_gps[n-1]))&&(floor(y_gps)==floor(y_inter_gps[n-1])))
  {
    u_xx=(((abs(angle[n-1])+abs(angle[n-2]))>(3.14/2))||(angle[n-1]>(3.14/4))||((angle[n-1]<0)&&(angle[n-2]<0)))?-u_x:u_x;
    u_yy=-(u_y-g*t_corr);
    theta=(3.14/2)-angle[n-1];
    t=0;// time is set to 0
    gd=floor(y_inter_gps[n-1]); // reference ground changed
    x_shift=floor(x_inter_gps[n-1]); //x shift changed     
    pre=n-1; 
  }

  t=t+1/delay;
  //ball
  fill(200,200,200);
  ellipse(x_gps,y_gps,r,r);  

  if(mousePressed==true)
  {
    line(a[n],b[n],c[n],d[n]);
  }
  line(a[n-1],b[n-1],c[n-1],d[n-1]);

// uncomment for illustrative purpose
// line(x_shift,gd,x_gps,gd);
// line(x_shift,gd,x_shift,y_gps);
}

void mousePressed()
{
  a[n]=mouseX;
  b[n]=mouseY;
  c[n]=pmouseX;
  d[n]=pmouseY;
}

void mouseDragged()
{
  c[n]=mouseX;
  d[n]=mouseY;
  val_ang=(atan((d[n]-b[n])/(c[n]-a[n]))/3.14)*180;
  x_ang=a[n]+10;
  y_ang=b[n]+10;
}

void mouseReleased()
{
  c[n]=mouseX;
  d[n]=mouseY;
  x_ang=-10;
  y_ang=-10;

  //get slope
  m_line=((d[n]-b[n])/(c[n]-a[n]));
  angle[n]=atan(m_line);
  //get y intercept
  c_line=b[n]-(a[n]*m_line);

  //converting gps parameters to ref and finding points of intersection
  a_quad=g;
  b_quad=-((2*g*x_shift)+(2*u_y*u_x)+(2*sq(u_x)*m_line));
  c_quad=((g*sq(x_shift))+(2*u_y*u_x*x_shift)+(2*gd*sq(u_x))-(2*sq(u_x)*c_line));  
  //x coordinate of intersection
  x_lower=((-(b_quad)-sqrt(sq(b_quad)-(4*a_quad*c_quad)))/(2*a_quad));
  x_upper=((-(b_quad)+sqrt(sq(b_quad)-(4*a_quad*c_quad)))/(2*a_quad));
  if((((x_lower<a[n])&&(x_lower>c[n]))||((x_lower<c[n])&&(x_lower>a[n])))||(((x_upper<a[n])&&(x_upper>c[n]))||((x_upper<c[n])&&(x_upper>a[n]))))
  {
    x_inter_gps[n]=(((x_lower<a[n])&&(x_lower>c[n]))||((x_lower<c[n])&&(x_lower>a[n])))?x_lower:x_upper;//slope +ve or -ve
    y_inter_gps[n]=(m_line*x_inter_gps[n])+c_line;
    x_inter=x_inter_gps[n]-x_shift;
    //time if intersection in quanta
    t_inter=floor((x_inter/(u_x))*10)/10;
    y_inter=(u_y*t_inter)-(.5*g*t_inter*t_inter); //value as per quanta
    y_inter_gps[n]=gd-y_inter; //wrt to gps
    x_inter=u_x*t_inter; //value as per quanta
    x_inter_gps[n]=x_inter+x_shift; //wrt to gps
    //incr n */
    n++;
  }  
}
