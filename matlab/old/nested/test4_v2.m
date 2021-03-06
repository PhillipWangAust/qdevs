clear all


%    
%
%          1    0.01        v1         1    100         v2
%    .----VVV---UUU----o---------o----VVV---UUU----o----------o
%   +|      --->       |         |      --->       |          |
%   ( ) 1    i1       === 0.1    < 1    i2        === 1000    < 1
%    |                 |         |                 |          |
%    '-----------------+---------'-----------------'----------'
%                     -+- 
%                      '
%

dQvoltage = 0.001;
dQcurrent = 0.001;
eps_factor = 0.25;

tstop = 10000;

run_ss = 1;

Rp1 = 1;
Rp2 = 1;
I1 = 0;
I2 = 0;
C1 = 0.1;
C2 = 1000;

E = 1;
Rs = 1;
L1 = 0.01;
L2 = 100;
Vref = 0;

% create the system:
sys = LiqssLimSystem2(dQvoltage, dQcurrent, eps_factor);

% define devices:
gnd1 = LiqssLimGround2('GRD', Vref);
rci1 = LiqssLimRCI('RCI1', Rp1, C1, I1, 0, dQvoltage, dQcurrent, eps_factor);
rci2 = LiqssLimRCI('RCI2', Rp2, C2, I2, 0, dQvoltage, dQcurrent, eps_factor);

% define and connect branches:
% branch1 = LiqssLimBranch('branch1', E, R, L1, 0, gnd, node1);
% branch2 = LiqssLimBranch('branch2', 0, R, L2, 0, node1, node2);

% add devices to system:
sys.add_device(gnd1);
sys.add_device(rci1);
sys.add_device(rci2);

% % initialize and run:
% tqss0 = cputime
% sys.init(0);
% sys.run(tstop*0.5);
% branch1.E = 2.0;
% sys.run(tstop);
% tqss1 = cputime
% 
% %   state space benchmark:
% %
% %   E  = i1*R + i1'*L + v1
% %   v1 = i2*R + i2'*L + v2
% %   i1 = v1*G + v1'*C + i2
% %   i2 = v2*G + v2'*C
% %
% %   i1' = 1/L * (E - i1*R - v1)
% %   i2' = 1/L * (v1 - i2*R - v2)
% %   v1' = 1/C * (i1 - v1*G - i2)
% %   v2' = 1/C * (i2 - v2*G)
% %
% %   i1' = i1 * -R/L  +  i2 *  0    +  v1 * -1/L  +  v2 *  0
% %   i2' = i1 *  0    +  i2 * -R/L  +  v1 *  1/L  +  v2 * -1/L
% %   v1' = i1 *  1/C  +  i2 * -1/C  +  v1 * -G/C  +  v2 *  0
% %   v2' = i1 *  0    +  i2 *  1/C  +  v1 *  0    +  v2 * -G/C
% 
% n = 4;
% h = 0.001;
% t = 0:h:tstop;
% x = double.empty(4, 0);
% 
% if run_ss
% 
%     a = [ -R/L1   0     -1/L1   0   ;
%            0     -R/L2   1/L2  -1/L2 ;
%            1/C1  -1/C1  -G/C1   0   ;
%            0      1/C2   0     -G/C2 ];
% 
%     b = [  1/L1   0     0     0   ]';
% 
%     u = [  E  ]';
% 
%     apr = inv(eye(n) - a * h);
%     bpr = apr * h * b;
% 
%     x = zeros(n, length(t));
%     
%     tss0 = cputime;
%     for k = 2:length(t)
%         if t(k-1) > tstop * 0.5;
%             u = [ 2.0 ];
%         end
%         x(:,k) = apr * x(:,k-1) + bpr * u; 
%     end
%     tss1 = cputime;
%     
% end
% 
% figure;
% 
% rows = 2
% cols = 2
% 
% subplot(rows, cols, 2);
% plot_qss(node1.thist, node1.qhist, x(3, :), t, 'voltage (V)', 'Node 1', run_ss);
% 
% subplot(rows, cols, 4);
% plot_qss(node2.thist, node2.qhist, x(4, :), t, 'voltage (V)', 'Node 2', run_ss);
% 
% subplot(rows, cols, 1);
% plot_qss(branch1.thist, branch1.qhist, x(1, :), t, 'current (A)', 'Branch 1', run_ss);
% 
% subplot(rows, cols, 3);
% plot_qss(branch2.thist, branch2.qhist, x(2, :), t, 'current (A)', 'Branch 2', run_ss);
% 
% tqss1 - tqss0;
% tss1 - tss0;
% 
% disp('done.');
% 
% function plot_qss(thist, qhist, xss, t, label, name, run_ss)
% 
%     plot_upds = 0;
% 
%     upd_max = 10000;
%     binwidth = 100; % updates per x seconds
% 
%     yyaxis left
%     
%     if run_ss
%         plot(t, xss, 'c--'); 
%     end
%     
%     hold on
%     
%     v1 = interp1(thist, qhist, t, 'previous');
%     plot(thist, qhist, 'k.');
%     plot(t, v1, 'b-');
%     
%     ylabel(label);
% 
%     if plot_upds
%         yyaxis right
% 
%         h1 = histogram(thist);
%         h1.BinWidth = binwidth;
%         h1.LineStyle = 'none';
% 
%         ax = gca;
%         %ax.XLim = [0 100];
%         %ax.YLim = [0 upd_max];
% 
%         ylabel(strcat('updates per', {'  '}, num2str(binwidth), ' s'));
%     
%     end
% 
%     xlabel('t (s)');
%     
%     if plot_upds
%         legend({'ss', 'qss', 'qss (zoh)', 'updates'}, 'Location', 'east');
%     else
%         legend({'ss', 'qss', 'qss (zoh)'}, 'Location', 'east');
%     end
%     
%     title(name);
% 
% end




