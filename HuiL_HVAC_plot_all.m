%% HuiL_HVAC_plot_all( results )
% Plots all the states and inputs in the HuiL HVAC system
%   in two figures: one for the SCT, one for the body and room.
%
% Inputs:
%   r: Results as output by HuiL_HVAC_mdl_all_sim.
% Outputs:
%   h1: Handle to SCT output figure
%   h2: Handle to body and room output figure
function h = HuiL_HVAC_plot_all(r)

h = zeros(2,1); % Create the handles for the two figures

%% Plot SCT model output
h(1) = figure('windowstyle','docked');

n = 1;
subplot(7,2,n); n=n+1; plot_var('xi_1',r);
subplot(7,2,n); n=n+1; plot_var('xi_2',r);
subplot(7,2,n); n=n+1; plot_var('xi_3',r);
subplot(7,2,n); n=n+1; plot_var('xi_4',r);
subplot(7,2,n); n=n+1; plot_var('xi_5',r);
subplot(7,2,n); n=n+1; plot_var('xi_6',r);
subplot(7,2,n); n=n+1; plot_var('xi_7',r);
subplot(7,2,n); n=n+1; plot_var('xi_8',r);
subplot(7,2,n); n=n+1; plot_var('eta_1',r);
subplot(7,2,n); n=n+1; plot_var('eta_2',r);
subplot(7,2,n); n=n+1; plot_var('eta_3',r);
subplot(7,2,n); n=n+1; plot_var('eta_4',r);
    hold on; plot(r.t, r.eta_4_thresh*ones(size(r.t)), 'r--');
subplot(7,2,n); n=n+1; plot_var('eta_5',r);
    xlabel('time $(hr)$', 'interpreter','latex')
subplot(7,2,n); n=n+1; plot_var('eta_6',r);
    xlabel('time $(hr)$', 'interpreter','latex')

%% Plot body physiology model output
h(2) = figure('windowstyle','docked');

% Room temperature
subplot(4,2,1)
    plot(r.t, r.T_r, 'b');
    hold on
    plot(r.t, r.T_b - 000.00, 'k','linewidth',2);
    plot(r.t, (r.T_b_ref - 000.00)*ones(size(r.t)), 'r--');
    title('Body physiology temperatures, $r.T_r , r.T_b , T_{b_{ref}} $ $( ^\circ C )$', ...
        'interpreter','latex');
    legend({'Room temperature ($r.T_r$)', ...
        'Body temperature ($r.T_b$)', ...
        'Ref. body temp. ($T_{b_{ref}}$)'}, ...
        'interpreter','latex', 'location','southeast');
    xlim([0 6]);
    
subplot(4,2,2)
    plot(r.t, r.T_r, 'b');
    hold on
    plot(r.t, r.T_b - 000.00, 'k','linewidth',2);
    plot(r.t, (r.T_b_ref - 000.00)*ones(size(r.t)), 'r--');
    title('Body physiology temperatures, $r.T_r , r.T_b , T_{b_{ref}} $ $( ^\circ C )$', ...
        'interpreter','latex');
    legend({'Room temperature ($r.T_r$)', ...
        'Body temperature ($r.T_b$)', ...
        'Ref. body temp. ($T_{b_{ref}}$)'}, ...
        'interpreter','latex', 'location','southeast');

% Metabolism
% TODO: Implement dynamic metabolism
subplot(4,2,3);
    plot(r.t, r.Q_met )
    title('Metabolic heating, $\dot{Q}_m$ ($W$)', ...
        'interpreter','latex');
    xlim([0 6]);
    
subplot(4,2,4);
    plot(r.t, r.Q_met )
    title('Metabolic heating, $\dot{Q}_m$ ($W$)', ...
        'interpreter','latex');
    
%% Plot room model

% Room Temperature
% TODO: Implement dynamic outside temperature
subplot(4,2,5)
    plot(r.t, r.T_out*ones(size(r.t)), 'b');
    hold on
    plot(r.t, r.T_r, 'k', 'linewidth',2);
    plot(r.t, r.T_r_ref, 'r--');
    title('Environment temperatures, $T_{r.out}, r.T_r, T_{r_{ref}}$ $( ^\circ C )$', ...
        'interpreter','latex');
    plot(r.t([0; diff(r.T_r_ref)]~=0), r.T_r_ref([0; diff(r.T_r_ref)]~=0), ...
        'r.', 'markersize', 15);
    legend({'Outside temperature ($T_{r.out}$)', ...
        'Room temperature ($r.T_r$)', ...
        'Ref. room temp. ($T_{r_{ref}}$)'}, ...
        'interpreter', 'latex', 'location','southeast');
    xlim([0 6]);
    
subplot(4,2,6)
    plot(r.t, r.T_out*ones(size(r.t)), 'b');
    hold on
    plot(r.t, r.T_r, 'k', 'linewidth',2);
    plot(r.t, r.T_r_ref, 'r--');
    title('Environment temperatures, $T_{r.out}, r.T_r, T_{r_{ref}}$ $( ^\circ C )$', ...
        'interpreter','latex');
    plot(r.t([0; diff(r.T_r_ref)]~=0), r.T_r_ref([0; diff(r.T_r_ref)]~=0), ...
        'r.', 'markersize', 15);
    legend({'Outside temperature ($T_{r.out}$)', ...
        'Room temperature ($r.T_r$)', ...
        'Ref. room temp. ($T_{r_{ref}}$)'}, ...
        'interpreter', 'latex', 'location','southeast');
   
% Room heat input
subplot(4,2,7)
    plot(r.t, r.Q_h /1000)
    title('Room heating (kW)', ...
        'interpreter','latex');
    xlabel('time $(hr)$', 'interpreter','latex')
    xlim([0 6]);
    
subplot(4,2,8)
    plot(r.t, r.Q_h /1000)
    title('Room heating (kW)', ...
        'interpreter','latex');
    xlabel('time $(hr)$', 'interpreter','latex')
    
%% Plot variable with labels
function plot_var(y_lbl, r, varargin)

    lbls = struct( ...
        'xi_1', 'Skill training ($\xi_1$)', ...
        'xi_2', 'Observed behavior ($\xi_2$)', ...
        'xi_3', 'Perceived support ($\xi_3$)', ...
        'xi_4', 'Internal cues ($\xi_4$)', ...
        'xi_5', 'Perceived barriers ($\xi_5$)', ...
        'xi_6', 'Intrapersonal states ($\xi_6$)', ...
        'xi_7', 'Environmental context ($\xi_7$)', ...
        'xi_8', 'External cues ($\xi_8$)', ...
        'eta_1', 'Self-management skills ($\eta_1$)', ...
        'eta_2', 'Outcome expectancy ($\eta_2$)', ...
        'eta_3', 'Self-efficacy ($\eta_3$)', ...
        'eta_4', 'Behavior ($\eta_4$)', ...
        'eta_5', 'Behavioral outcomes ($\eta_5$)', ...
        'eta_6', 'Cue to action ($\eta_6$)');

    r.t = r.out.tout;
    xi = getfield( get(r.out.yout,'xi'), 'Values', 'Data');
    eta = getfield( get(r.out.yout,'eta'), 'Values', 'Data');

    x_nv = split(y_lbl,'_');
    x = eval([x_nv{1} '(:,' x_nv{2} ')']);

    if strcmp(x_nv{1}, 'eta')
        varargin = {'k', varargin{:}};
    elseif strcmp(x_nv{1}, 'xi')
        varargin = {'b--', varargin{:}};
    end

    plot(r.t, x, varargin{:});
    xlim([0 max(r.t)]);
    ylabel(['$\' y_lbl '$'], 'interpreter','latex');
    legend({lbls.(y_lbl)}, 'interpreter','latex');

    if strcmp(x_nv{1}, 'eta')
        ylim([0 100]);
    end
end

end