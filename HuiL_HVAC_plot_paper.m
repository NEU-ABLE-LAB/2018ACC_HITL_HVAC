function HuiL_HVAC_plot_paper(r)
%% plots all the important HuiL HVAC states and inputs for the ACC paper

%% Extract useful variables
t = r.out.tout;
T_b = getfield( get(r.out.yout,'T_b'), ...
    'Values', 'Data');
T_r = getfield( get(r.out.yout,'T_r'), ...
    'Values', 'Data');
T_r_ref = getfield( get(r.out.yout,'T_r_ref'), ...
    'Values', 'Data');
Q_h = getfield( get(r.out.yout,'Q_h'), ...
    'Values', 'Data');
Q_met = getfield( get(r.out.yout,'Q_met'), ...
    'Values', 'Data');
xi = getfield( get(r.out.yout,'xi'), ...
    'Values', 'Data');
eta = getfield( get(r.out.yout,'eta'), ...
    'Values', 'Data');

%% Plot
make_subplots([0 12]);

function make_subplots(x_lim)
%% Make all the subplots for a given xim
    
    % Plot SCT inputs
    hFig = figure('Units', 'Inches', ...
        'Position', [0, 0, 3.4, 3.74], ...
        'PaperUnits', 'Inches', 'PaperSize', [3.4, 3.74], ...
        'defaultAxesFontSize',8);
    cmap = colormap('lines');
    n=1;
    N=6;

    % xi_4 - Internal cues
    subplot(N,1,n); n=n+1;
    plot(t, xi(:,4), 'color',cmap(1,:));
    ylabel('$\xi_{4}$', 'interpreter','latex');
    legend({'$\xi_4$'}, 'interpreter','latex');

    % eta_1..6
    lbls = struct( ...
        'eta_1', 'Self-management skills ($\eta_1$)', ...
        'eta_2', 'Outcome expectancy ($\eta_2$)', ...
        'eta_3', 'Self-efficacy ($\eta_3$)', ...
        'eta_4', 'Behavior ($\eta_4$)', ...
        'eta_5', 'Behavioral outcomes ($\eta_5$)', ...
        'eta_6', 'Cue to action ($\eta_6$)');
        
    subplot(N,1,n:n+1); n=n+2;
        plot(t, eta(:,1), 'color',cmap(2,:));
        hold all;
        plot(t, eta(:,2), 'color',cmap(3,:));
        plot(t, eta(:,3), 'color',cmap(4,:));
        plot(t, eta(:,5), 'color',cmap(5,:));
        ylabel('$\eta_{1..3,5..6}$', 'interpreter','latex');
        legend({'$\eta_1$','$\eta_2$','$\eta_3$','$\eta_5$'}, 'interpreter','latex','orientation','horizontal')
    subplot(N,1,n); n=n+1;
        plot(t, eta(:,4), 'color',cmap(6,:));
        hold on;
        plot(t, eta(:,6), 'color',cmap(7,:));
        plot(t, 50*ones(size(t)), 'r--');
        ylabel('$\eta_{4}$', 'interpreter','latex');
        legend({'$\eta_4$','$\eta_6$'}, 'interpreter','latex','orientation','horizontal')

    
    % Plot body physiology model output
    subplot(N,1,n); n=n+1;
    plot(r.t, r.T_r, 'b');
    hold on
    plot(r.t, r.T_b - 000.00, 'k','linewidth',2);
    plot(r.t, (r.T_b_ref - 000.00)*ones(size(r.t)), 'r--');
    legend({'$T_r$', ...
        '$T_b$', ...
        '$T_{b_{ref}}$'}, ...
        'interpreter','latex', 'location','southeast','orientation','horizontal');
    ylabel('$^{\circ}C$', 'interpreter','latex');
    
    % Plot room model
    subplot(N,1,n); n=n+1;
    plot(r.t, r.T_out*ones(size(r.t)), 'b');
    hold on
    plot(r.t, r.T_r, 'k', 'linewidth',2);
    plot(r.t, r.T_r_ref, 'r--');
    plot(r.t([0; diff(r.T_r_ref)]~=0), r.T_r_ref([0; diff(r.T_r_ref)]~=0), ...
        'r.', 'markersize', 15);
    legend({'$T_{out}$', ...
        '$T_r$', ...
        '$T_{r_{ref}}$'}, ...
        'interpreter', 'latex', 'location','southeast','orientation','horizontal');
    ylabel('$^{\circ}C$', 'interpreter','latex');

    % Join x-axes
    samexaxis('join','ytac','yld',1);
    xlim(x_lim);
    
end

function plot_etaM(n, m)
    %% Plot state eta_m on subplot n
    lbls = struct( ...
        'eta_1', 'Self-management skills ($\eta_1$)', ...
        'eta_2', 'Outcome expectancy ($\eta_2$)', ...
        'eta_3', 'Self-efficacy ($\eta_3$)', ...
        'eta_4', 'Behavior ($\eta_4$)', ...
        'eta_5', 'Behavioral outcomes ($\eta_5$)', ...
        'eta_6', 'Cue to action ($\eta_6$)');
    
    subplot(N,1,n); n=n+1;
    plot(t, eta(:,m), 'k');
    ylabel(sprintf('$\\eta_%d$', m), 'interpreter','latex');
    legend({lbls.(sprintf('eta_%d', m))}, ...
        'interpreter','latex')
end

end