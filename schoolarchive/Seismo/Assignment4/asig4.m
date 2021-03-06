clear all
close all

t = 0; dx = 1; dt= 0.1; tlen = 5; tmax=33; beta=4; 
u1 = zeros(1,101); u2 = zeros(1,101); u3 = zeros(1,101);
x = 0:100; f=1;

%for j = 1:length(tmax)

    while t < tmax
    t=t+dt;
    for i =2:100
        rhs=beta^2*(u2(i+1)-2*u2(i)+u2(i-1))/dx^2;
        u3(i)=dt^2*rhs+2*u2(i)-u1(i);
    end
    u3(1)=u3(2);
    u3(101)=0;
    if(t<tlen)
        u3(51)=sin(pi*t/tlen)^2;
    end
    for i=1:101
        u1(i)=u2(i);
        u2(i)=u3(i);
    end

    if any(10:40:330 == round(t*10))
        subplot(3,3,f)
        plot(x,u3)
        ylim([-1.2,1.2])
        xlim([0,100])
        grid on
        title(sprintf('Pulse at t = %d seconds',round(t*10)/10))
        f=f+1;
        
    end

    end




