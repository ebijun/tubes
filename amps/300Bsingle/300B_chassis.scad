// =================================================================
// 300B シングル パワーアンプ 3D実体配線対応 OpenSCAD スクリプト
// シャーシ規格: 奥沢 O-18 (300 x 170 x 60 mm)
// =================================================================

$fn = 30; // 描画解像度

// -----------------------------------------------------------------
// 1. 配線表示コントロールフラグ (true: 表示 / false: 非表示)
// -----------------------------------------------------------------
show_heater = true; // ヒーター/フィラメント配線 (黄色/オレンジ)
show_power  = true; // B電源・高圧配線 (赤色)
show_signal = true; // 信号配線 (青色/緑色)
show_gnd    = true; // アース配線 (黒色/銅色母線)

// -----------------------------------------------------------------
// 2. シャーシ基本寸法 (spec.ods 準拠)
// -----------------------------------------------------------------
chassis_w = 300; // 幅 (W)
chassis_d = 170; // 奥行き (D)
chassis_h = 60;  // 高さ (H)
thick     = 1;   // 板厚 (アルミ 1mm)
flange    = 10;  // 底面板折り返し幅 (10mm)

// -----------------------------------------------------------------
// 3. 加工穴寸法およびピッチ設定 (mm)
// -----------------------------------------------------------------
hole_300b      = 30;  // 300B / 5U4GB ソケット穴径
hole_6463      = 22;  // 6463 MTソケット穴径
screw_hole_m3  = 3.2; // M3ビス穴径
pitch_socket_300b = 38; // 300B/5U4GB ソケット固定ネジピッチ
pitch_socket_6463 = 28; // 6463 MTソケット固定ネジピッチ

trans_power_cut   = [50, 40]; // パワートランス MX-200 配線角穴
trans_power_pitch = [70, 60]; // パワートランス固定ボルトピッチ
trans_out_cut     = [35, 35]; // 出力トランス FX-50-2.5 配線角穴
trans_out_pitch   = [55, 45]; // 出力トランス固定ボルトピッチ

hole_volume = 8;   // 天板ボリューム (VR) 軸穴径
hole_rca    = 10;  // RCAジャック穴径
hole_term   = 10;  // スピーカーターミナル穴径
bottom_hole = 3.2; // 底面固定用ビス穴

// -----------------------------------------------------------------
// 4. 配置座標 [X, Y, Z]
// -----------------------------------------------------------------
// トランス群 (最後列 Y: 125~130mm)
pos_trans_out_1 = [ 55, 130, chassis_h];
pos_trans_out_2 = [145, 130, chassis_h];
pos_trans_power = [240, 125, chassis_h];

// 真空管群 (Z: シャーシ裏面 50mm 位置にソケットピン)
pos_6463_l      = [ 60,  45, 50]; // 6463 L-ch
pos_6463_r      = [110,  45, 50]; // 6463 R-ch
pos_300b_l      = [170,  75, 45]; // 300B L-ch
pos_300b_r      = [230,  75, 45]; // 300B R-ch
pos_5u4gb       = [275,  75, 45]; // 5U4GB 整流管

// 天板ボリューム (2本MT管 6463 の手前天板位置)
pos_volume      = [ 85,  18, chassis_h]; 

// 背面端子
pos_rca_l       = [ 25, 170, 35];
pos_rca_r       = [ 45, 170, 35];
pos_sp_l        = [255, 170, 30];
pos_sp_r        = [275, 170, 30];

// アース母線 (シャーシ内部)
bus_bar_start   = [ 40,  55, 40];
bus_bar_end     = [260,  55, 40];

// ラグ板位置
pos_tag_l       = [ 85,  55, 45];
pos_tag_r       = [200,  55, 45];
pos_tag_pwr     = [150,  90, 40];

// -----------------------------------------------------------------
// 5. 配線描画モジュール
// -----------------------------------------------------------------
module wire(p1, p2, dia=1.2, wire_color=[1,0,0]) {
    color(wire_color) {
        dx = p2[0] - p1[0];
        dy = p2[1] - p1[1];
        dz = p2[2] - p1[2];
        len = sqrt(dx*dx + dy*dy + dz*dz);
        if (len > 0) {
            translate(p1)
                rotate([0, acos(dz/len), atan2(dy, dx)])
                    cylinder(h=len, d=dia);
        }
    }
}

// -----------------------------------------------------------------
// 6. 各種コンポーネントモジュール
// -----------------------------------------------------------------
module socket_mounting_holes(pitch, d=screw_hole_m3, angle=0) {
    rotate([0, 0, angle]) {
        translate([-pitch/2, 0, 0]) cylinder(h=10, d=d, center=true);
        translate([ pitch/2, 0, 0]) cylinder(h=10, d=d, center=true);
    }
}

module trans_mounting_holes(pitch_x, pitch_y, d=screw_hole_m3) {
    translate([-pitch_x/2, -pitch_y/2, 0]) cylinder(h=10, d=d, center=true);
    translate([ pitch_x/2, -pitch_y/2, 0]) cylinder(h=10, d=d, center=true);
    translate([-pitch_x/2,  pitch_y/2, 0]) cylinder(h=10, d=d, center=true);
    translate([ pitch_x/2,  pitch_y/2, 0]) cylinder(h=10, d=d, center=true);
}

module tag_board(length=60, width=12) {
    color([0.5, 0.35, 0.2, 0.9]) {
        cube([length, width, 2], center=true);
        for(x = [-length/2 + 5 : 10 : length/2 - 5]) {
            translate([x, 0, 4]) cube([1.5, 6, 6], center=true);
        }
    }
}

module cap_coupling() {
    color([1.0, 0.8, 0.2])
        rotate([0, 90, 0]) cylinder(h=25, d=12, center=true);
}

module cap_electrolytic(h=35, d=16) {
    color([0.2, 0.3, 0.8]) cylinder(h=h, d=d, center=true);
}

module resistor_power() {
    color([0.9, 0.9, 0.85]) cube([22, 9, 9], center=true);
}

module volume_pot_top() {
    translate([0, 0, -15]) color([0.2, 0.6, 0.3]) cube([25, 25, 18], center=true);
    color([0.8, 0.8, 0.8]) cylinder(h=20, d=6, center=true);
    translate([0, 0, 10]) color([0.1, 0.1, 0.1]) cylinder(h=15, d=20, center=true);
}

module octal_socket() {
    color([0.1, 0.1, 0.1, 0.9]) {
        cylinder(h=12, d=33, center=true);
        translate([0, 0, -6]) cylinder(h=4, d=8, center=true);
    }
}

module ground_bus_bar(p1, p2, dia=2.0) {
    color([0.85, 0.53, 0.26]) wire(p1, p2, dia=dia, wire_color=[0.85, 0.53, 0.26]);
}

// -----------------------------------------------------------------
// 7. シャーシ構造モジュール
// -----------------------------------------------------------------
module chassis_okuzawa_o18_full() {
    difference() {
        color([0.7, 0.7, 0.75, 0.3]) 
            difference() {
                cube([chassis_w, chassis_d, chassis_h]);
                translate([thick, thick, -thick])
                    cube([chassis_w - thick*2, chassis_d - thick*2, chassis_h]);
                translate([flange, flange, -1])
                    cube([chassis_w - flange*2, chassis_d - flange*2, thick + 2]);
            }
        
        z_pos = chassis_h - thick;
        
        translate([pos_volume[0], pos_volume[1], z_pos]) cylinder(h=5, d=hole_volume, center=true);

        translate([pos_trans_out_1[0], pos_trans_out_1[1], z_pos]) {
            cube([trans_out_cut[0], trans_out_cut[1], 5], center=true);
            trans_mounting_holes(trans_out_pitch[0], trans_out_pitch[1]);
        }
        translate([pos_trans_out_2[0], pos_trans_out_2[1], z_pos]) {
            cube([trans_out_cut[0], trans_out_cut[1], 5], center=true);
            trans_mounting_holes(trans_out_pitch[0], trans_out_pitch[1]);
        }
        translate([pos_trans_power[0], pos_trans_power[1], z_pos]) {
            cube([trans_power_cut[0], trans_power_cut[1], 5], center=true);
            trans_mounting_holes(trans_power_pitch[0], trans_power_pitch[1]);
        }

        translate([pos_6463_l[0], pos_6463_l[1], z_pos]) {
            cylinder(h=5, d=hole_6463, center=true);
            socket_mounting_holes(pitch_socket_6463, angle=0);
        }
        translate([pos_6463_r[0], pos_6463_r[1], z_pos]) {
            cylinder(h=5, d=hole_6463, center=true);
            socket_mounting_holes(pitch_socket_6463, angle=0);
        }

        translate([pos_300b_l[0], pos_300b_l[1], z_pos]) {
            cylinder(h=5, d=hole_300b, center=true);
            socket_mounting_holes(pitch_socket_300b, angle=45);
        }
        translate([pos_300b_r[0], pos_300b_r[1], z_pos]) {
            cylinder(h=5, d=hole_300b, center=true);
            socket_mounting_holes(pitch_socket_300b, angle=45);
        }
        
        translate([pos_5u4gb[0], pos_5u4gb[1], z_pos]) {
            cylinder(h=5, d=hole_5u4gb, center=true);
            socket_mounting_holes(pitch_socket_300b, angle=0);
        }

        translate([pos_rca_l[0], chassis_d - 1, pos_rca_l[2]]) rotate([-90, 0, 0]) cylinder(h=thick + 2, d=hole_rca);
        translate([pos_rca_r[0], chassis_d - 1, pos_rca_r[2]]) rotate([-90, 0, 0]) cylinder(h=thick + 2, d=hole_rca);
        translate([pos_sp_l[0], chassis_d - 1, pos_sp_l[2]]) rotate([-90, 0, 0]) cylinder(h=thick + 2, d=hole_term);
        translate([pos_sp_r[0], chassis_d - 1, pos_sp_r[2]]) rotate([-90, 0, 0]) cylinder(h=thick + 2, d=hole_term);

        y_hole = 4;
        translate([30, y_hole, -1]) cylinder(h=thick+2, d=bottom_hole);
        translate([270, y_hole, -1]) cylinder(h=thick+2, d=bottom_hole);
        translate([30, chassis_d - y_hole, -1]) cylinder(h=thick+2, d=bottom_hole);
        translate([270, chassis_d - y_hole, -1]) cylinder(h=thick+2, d=bottom_hole);
        translate([y_hole, 120, -1]) cylinder(h=thick+2, d=bottom_hole);
        translate([chassis_w - y_hole, 120, -1]) cylinder(h=thick+2, d=bottom_hole);
    }
}

// -----------------------------------------------------------------
// 8. 3D 実体配線描画ルーチン
// -----------------------------------------------------------------
module draw_3d_wiring() {
    // 1. ヒーター/フィラメント配線 (黄色/オレンジ)
    if (show_heater) {
        // パワートランス -> 5U4GB (Pin 2, 8) 5V
        wire(pos_trans_power + [0, -10, -10], pos_5u4gb + [-10, 0, -5], 1.5, [1, 0.8, 0]);
        wire(pos_trans_power + [5, -10, -10], pos_5u4gb + [ 10, 0, -5], 1.5, [1, 0.8, 0]);

        // パワートランス -> 300B L/R (Pin 1, 4) 5V/4.3V
        wire(pos_trans_power + [-10, -10, -10], pos_300b_l + [-12, 0, -5], 1.5, [1, 0.6, 0]);
        wire(pos_trans_power + [-15, -10, -10], pos_300b_r + [-12, 0, -5], 1.5, [1, 0.6, 0]);

        // パワートランス -> 6463 L/R (Pin 4, 5) 6.3V
        wire(pos_trans_power + [-20, -10, -10], pos_6463_l + [-8, -8, -5], 1.2, [0.9, 0.9, 0]);
        wire(pos_6463_l + [8, -8, -5], pos_6463_r + [-8, -8, -5], 1.2, [0.9, 0.9, 0]);
    }

    // 2. B電源・高圧配線 (赤色)
    if (show_power) {
        // パワートランス 380V -> 5U4GB (Pin 4, 6)
        wire(pos_trans_power + [10, -10, -10], pos_5u4gb + [0, -12, -5], 1.5, [0.9, 0.1, 0.1]);
        wire(pos_trans_power + [15, -10, -10], pos_5u4gb + [0,  12, -5], 1.5, [0.9, 0.1, 0.1]);

        // 5U4GB (Pin 8) -> 平滑電解コンデンサ (B+1)
        wire(pos_5u4gb + [10, 0, -5], pos_tag_pwr + [-20, 0, -10], 1.5, [0.9, 0.1, 0.1]);

        // B+1 -> 出力トランス 1 & 2 Primary-B
        wire(pos_tag_pwr + [-20, 0, -10], pos_trans_out_1 + [0, -10, -10], 1.2, [0.9, 0.1, 0.1]);
        wire(pos_tag_pwr + [-20, 0, -10], pos_trans_out_2 + [0, -10, -10], 1.2, [0.9, 0.1, 0.1]);

        // B+1 -> 降圧抵抗 -> デカップリングコンデンサ (B+2) -> 6463 プレート抵抗
        wire(pos_tag_pwr + [-20, 0, -10], pos_tag_pwr + [0, 0, -10], 1.2, [0.8, 0.2, 0.2]);
        wire(pos_tag_pwr + [0, 0, -10], pos_tag_l + [20, 0, -5], 1.2, [0.8, 0.2, 0.2]);
        wire(pos_tag_pwr + [0, 0, -10], pos_tag_r + [20, 0, -5], 1.2, [0.8, 0.2, 0.2]);
    }

    // 3. 信号配線 (青色/緑色)
    if (show_signal) {
        // RCA -> VR (入力信号)
        wire(pos_rca_l + [0, -2, 0], pos_volume + [-8, 12, -15], 1.0, [0.1, 0.7, 0.3]);
        wire(pos_rca_r + [0, -2, 0], pos_volume + [ 8, 12, -15], 1.0, [0.1, 0.7, 0.3]);

        // VR -> 6463 入力グリッド
        wire(pos_volume + [-5, 12, -15], pos_6463_l + [0, -8, -5], 1.0, [0.2, 0.4, 0.9]);
        wire(pos_volume + [ 5, 12, -15], pos_6463_r + [0, -8, -5], 1.0, [0.2, 0.4, 0.9]);

        // 6463 プレート -> 結合コンデンサ -> 300B グリッド
        wire(pos_6463_l + [0, 8, -5], pos_tag_l + [-15, 0, -5], 1.0, [0.2, 0.4, 0.9]);
        wire(pos_tag_l + [15, 0, -5], pos_300b_l + [0, -12, -5], 1.0, [0.2, 0.4, 0.9]);

        wire(pos_6463_r + [0, 8, -5], pos_tag_r + [-15, 0, -5], 1.0, [0.2, 0.4, 0.9]);
        wire(pos_tag_r + [15, 0, -5], pos_300b_r + [0, -12, -5], 1.0, [0.2, 0.4, 0.9]);

        // 300B プレート -> 出力トランス Primary-P
        wire(pos_300b_l + [0, 12, -5], pos_trans_out_1 + [10, -10, -10], 1.2, [0.1, 0.5, 0.8]);
        wire(pos_300b_r + [0, 12, -5], pos_trans_out_2 + [10, -10, -10], 1.2, [0.1, 0.5, 0.8]);

        // 出力トランス Secondary -> スピーカー端子
        wire(pos_trans_out_1 + [-10, 10, -10], pos_sp_l + [0, -2, 0], 1.5, [0.1, 0.8, 0.2]);
        wire(pos_trans_out_2 + [-10, 10, -10], pos_sp_r + [0, -2, 0], 1.5, [0.1, 0.8, 0.2]);
    }

    // 4. アース配線 (黒色)
    if (show_gnd) {
        // 各コンデンサ/ラグ板/ソケットからアース母線への落とし込み
        wire(pos_tag_pwr + [20, 0, -10], [170, 55, 40], 1.5, [0.1, 0.1, 0.1]);
        wire(pos_tag_l + [-25, 0, -5],   [ 60, 55, 40], 1.2, [0.1, 0.1, 0.1]);
        wire(pos_tag_r + [-25, 0, -5],   [240, 55, 40], 1.2, [0.1, 0.1, 0.1]);
        wire(pos_rca_l + [0, 2, -5],     [ 40, 55, 40], 1.2, [0.1, 0.1, 0.1]);
    }
}

// -----------------------------------------------------------------
// 9. 最終組み立てアセンブリ
// -----------------------------------------------------------------

// シャーシ本体
chassis_okuzawa_o18_full();

// 5U4GB 用 US オクタルソケット
translate([pos_5u4gb[0], pos_5u4gb[1], chassis_h - 6]) octal_socket();

// 天板取付けボリューム
translate([pos_volume[0], pos_volume[1], chassis_h]) volume_pot_top();

// アース母線 (太銅線 2.0mm)
ground_bus_bar(bus_bar_start, bus_bar_end, dia=2.0);

// 内部配線ラグ板
translate(pos_tag_l) {
    tag_board(60, 12);
    translate([0, 0, -8]) cap_coupling();
    translate([15, 0, -10]) resistor_power();
}
translate(pos_tag_r) {
    tag_board(60, 12);
    translate([0, 0, -8]) cap_coupling();
    translate([-15, 0, -10]) resistor_power();
}
translate(pos_tag_pwr) {
    rotate([0, 0, 90]) tag_board(60, 12);
    translate([-20, 0, -10]) cap_electrolytic(40, 22);
    translate([ 20, 0, -10]) cap_electrolytic(40, 22);
    translate([  0, 0, -10]) resistor_power();
}

// 3D実体配線ライン描画実行
draw_3d_wiring();

