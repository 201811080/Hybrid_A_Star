% ==============================================================================
%  MATLAB Source Codes for the book "Cooperative Dedcision and Planning for
%  Connected and Automated Vehicles" published by Mechanical Industry Press
%  in 2020.
% ��������������Эͬ������滮�������鼮���״���
%  Copyright (C) 2020 Bai Li
%  2020.01.29
% ==============================================================================
%  �ڶ���. 2.4.3С��. ���A���㷨ʵ��·�����ߣ���һ�ִ��Եľֲ�·���滮�������ֽ��
% ==============================================================================
%  ��ע��
%  1. ͼ����ʾ��·�������Գ������������ĵ��ƶ����ɵ�·��
% ==============================================================================
close all
clc

% % ��������
global vehicle_geometrics_ % �����������γߴ�
vehicle_geometrics_.vehicle_wheelbase = 2.8;
vehicle_geometrics_.vehicle_front_hang = 0.96;
vehicle_geometrics_.vehicle_rear_hang = 0.929;
vehicle_geometrics_.vehicle_width = 1.942;
vehicle_geometrics_.vehicle_length = vehicle_geometrics_.vehicle_wheelbase + vehicle_geometrics_.vehicle_front_hang + vehicle_geometrics_.vehicle_rear_hang;
vehicle_geometrics_.radius = hypot(0.25 * vehicle_geometrics_.vehicle_length, 0.5 * vehicle_geometrics_.vehicle_width);
vehicle_geometrics_.r2x = 0.25 * vehicle_geometrics_.vehicle_length - vehicle_geometrics_.vehicle_rear_hang;
vehicle_geometrics_.f2x = 0.75 * vehicle_geometrics_.vehicle_length - vehicle_geometrics_.vehicle_rear_hang;
global vehicle_kinematics_ % �����˶���������
vehicle_kinematics_.vehicle_v_max = 2.5;
vehicle_kinematics_.vehicle_a_max = 0.5;
vehicle_kinematics_.vehicle_phy_max = 0.7;
vehicle_kinematics_.vehicle_w_max = 0.5;
vehicle_kinematics_.vehicle_kappa_max = tan(vehicle_kinematics_.vehicle_phy_max) / vehicle_geometrics_.vehicle_wheelbase;
vehicle_kinematics_.vehicle_turning_radius_min = 1 / vehicle_kinematics_.vehicle_kappa_max;
global environment_scale_ % �������ڻ�����Χ
environment_scale_.environment_x_min = -20;
environment_scale_.environment_x_max = 20;
environment_scale_.environment_y_min = -20;
environment_scale_.environment_y_max = 20;
environment_scale_.x_scale = environment_scale_.environment_x_max - environment_scale_.environment_x_min;
environment_scale_.y_scale = environment_scale_.environment_y_max - environment_scale_.environment_y_min;

% % ����ȶ�����
global vehicle_TPBV_ obstacle_vertexes_
load Case_103.mat

global hybrid_astar_ % ���A���㷨�漰�Ĳ���
hybrid_astar_.resolution_x = 0.2;
hybrid_astar_.resolution_y = 0.2;
hybrid_astar_.resolution_theta = 0.2;
hybrid_astar_.num_nodes_x = ceil(environment_scale_.x_scale / hybrid_astar_.resolution_x) + 1;
hybrid_astar_.num_nodes_y = ceil(environment_scale_.y_scale / hybrid_astar_.resolution_y) + 1;
hybrid_astar_.num_nodes_theta = ceil(2 * pi / hybrid_astar_.resolution_theta) + 1;
hybrid_astar_.penalty_for_backward = 1;
hybrid_astar_.penalty_for_direction_changes = 3;
hybrid_astar_.penalty_for_steering_changes = 0;
hybrid_astar_.multiplier_H = 5.0;
hybrid_astar_.multiplier_H_for_A_star = 2.0;
hybrid_astar_.max_iter = 500;
hybrid_astar_.max_time = 5;
hybrid_astar_.simulation_step = 0.7;
hybrid_astar_.Nrs = 10;

% % ���ƻ������ϰ���ڷ����
figure(1)
axis equal; box on; grid on; axis([environment_scale_.environment_x_min environment_scale_.environment_x_max ...
    environment_scale_.environment_y_min environment_scale_.environment_y_max]);
set(gcf,'outerposition',get(0,'screensize')); hold on;
for ii = 1 : length(obstacle_vertexes_)
    fill(obstacle_vertexes_{ii}.x, obstacle_vertexes_{ii}.y, [125, 125, 125] ./ 255);
end
Arrow([vehicle_TPBV_.x0, vehicle_TPBV_.y0], [vehicle_TPBV_.x0 + cos(vehicle_TPBV_.theta0), vehicle_TPBV_.y0 + sin(vehicle_TPBV_.theta0)], 'Length',16,'BaseAngle',90,'TipAngle',16,'Width',2);
Arrow([vehicle_TPBV_.xtf, vehicle_TPBV_.ytf], [vehicle_TPBV_.xtf + cos(vehicle_TPBV_.thetatf), vehicle_TPBV_.ytf+ sin(vehicle_TPBV_.thetatf)],  'Length',16,'BaseAngle',90,'TipAngle',16,'Width',2);
xlabel('x / m','FontSize',16);
ylabel('y / m','FontSize',16);
drawnow

% % ���û��A���㷨����·��������ɹ�������ʾ����·��
[x, y, theta, path_length, completeness_flag] = SearchHybridAStarPath();
if (completeness_flag)
    for ii = 1 : length(x)
        V = CreateVehiclePolygon(x(ii), y(ii), theta(ii));
        plot(V(:,1), V(:,2), 'b'); drawnow
    end
    plot(x,y,'k','LineWidth',2); drawnow
end