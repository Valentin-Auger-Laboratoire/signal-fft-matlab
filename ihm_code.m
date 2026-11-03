% Code extrait de l'application App Designer (lecture seule ; l'IHM d'origine
% contenait des visuels sous droits, retirés de la publication)
%
% Les composants décoratifs (images, son) ont été supprimés ; seuls restent les
% graphiques (UIAxes), curseurs, boutons et champs. Les appels sont alignés sur
% les fonctions corrigées du dépôt (voir la section « Interface App Designer »
% du README pour la liste des écarts).

classdef ihm_code < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                        matlab.ui.Figure
        TabGroup                        matlab.ui.container.TabGroup
        AccueilTab                      matlab.ui.container.Tab
        DescriptionLabel                matlab.ui.control.Label
        TitreLabel                      matlab.ui.control.Label
        SignalTab                       matlab.ui.container.Tab
        MenusignalLabel                 matlab.ui.control.Label
        ParamtreLabel                   matlab.ui.control.Label
        feSlider                        matlab.ui.control.Slider
        feSliderLabel                   matlab.ui.control.Label
        f3Slider                        matlab.ui.control.Slider
        f3SliderLabel                   matlab.ui.control.Label
        f2Slider                        matlab.ui.control.Slider
        f2SliderLabel                   matlab.ui.control.Label
        f1Slider                        matlab.ui.control.Slider
        f1SliderLabel                   matlab.ui.control.Label
        A3Slider                        matlab.ui.control.Slider
        A3SliderLabel                   matlab.ui.control.Label
        A2Slider                        matlab.ui.control.Slider
        A2SliderLabel                   matlab.ui.control.Label
        A1Slider                        matlab.ui.control.Slider
        A1SliderLabel                   matlab.ui.control.Label
        MSlider                         matlab.ui.control.Slider
        MSliderLabel                    matlab.ui.control.Label
        UIAxes                          matlab.ui.control.UIAxes
        ErreurTab                       matlab.ui.container.Tab
        NonlinairePanel                 matlab.ui.container.Panel
        dformationnonlinaireButtonGroup  matlab.ui.container.ButtonGroup
        logarithmiqueButton             matlab.ui.control.RadioButton
        exponentielleButton             matlab.ui.control.RadioButton
        P1Slider                        matlab.ui.control.Slider
        P1SliderLabel                   matlab.ui.control.Label
        P0Slider                        matlab.ui.control.Slider
        P0SliderLabel                   matlab.ui.control.Label
        linairePanel                    matlab.ui.container.Panel
        OFFSETSlider                    matlab.ui.control.Slider
        OFFSETSliderLabel               matlab.ui.control.Label
        dformationlinaireButtonGroup    matlab.ui.container.ButtonGroup
        OFFSETGainButton                matlab.ui.control.RadioButton
        GainOFFSETButton                matlab.ui.control.RadioButton
        OFFSETButton                    matlab.ui.control.RadioButton
        GainButton                      matlab.ui.control.RadioButton
        GainSlider                      matlab.ui.control.Slider
        GainSliderLabel                 matlab.ui.control.Label
        choixdeladformationButtonGroup  matlab.ui.container.ButtonGroup
        nonlinaireButton                matlab.ui.control.ToggleButton
        linaireButton                   matlab.ui.control.ToggleButton
        ParamtreLabel_2                 matlab.ui.control.Label
        MenuErreurLabel                 matlab.ui.control.Label
        UIAxes2                         matlab.ui.control.UIAxes
        FFTTab                          matlab.ui.container.Tab
        FrquencefondamentaleEditField   matlab.ui.control.NumericEditField
        FrquencefondamentaleEditFieldLabel  matlab.ui.control.Label
        MenuFFTLabel                    matlab.ui.control.Label
        UIAxes3                         matlab.ui.control.UIAxes
        EstimationTab                   matlab.ui.container.Tab
        P1estimeEditField               matlab.ui.control.NumericEditField
        P1estimeEditFieldLabel          matlab.ui.control.Label
        P0estimeEditField               matlab.ui.control.NumericEditField
        P0estimeEditFieldLabel          matlab.ui.control.Label
        TypedformationDropDown          matlab.ui.control.DropDown
        TypedformationDropDownLabel     matlab.ui.control.Label
        MenuEstimationLabel             matlab.ui.control.Label
        UIAxes5                         matlab.ui.control.UIAxes
        CorrectionTab                   matlab.ui.container.Tab
        MenuCorrectionLabel             matlab.ui.control.Label
        UIAxes5_2                       matlab.ui.control.UIAxes
        OptionTab                       matlab.ui.container.Tab
        ExporterenPDFButton             matlab.ui.control.Button
        OptiondexportationdefichierLabel  matlab.ui.control.Label
        ExporteruncsvButton             matlab.ui.control.Button
        DebugButton                     matlab.ui.control.StateButton
        MenuOptionLabel                 matlab.ui.control.Label
        OptionsuprautilisateurLabel     matlab.ui.control.Label
    end


    properties (Access = private)
        DebugMode = false; % Désactivé par défaut
        s                  % Signal original partagé
        sd                 % Signal déformé partagé
    end

    methods (Access = private)
            % Lecture des paramètres du signal depuis les curseurs.
            % Les estimateurs supposent des Fi entières et 0 < Fi < fe/2 : Fi et fe
            % sont arrondis, et fe est borné par les limites de son curseur.
            function [M, Ai, Fi, Fe] = lireParametres(app)
                M  = app.MSlider.Value;
                Ai = [app.A1Slider.Value, app.A2Slider.Value, app.A3Slider.Value];
                Fi = round([app.f1Slider.Value, app.f2Slider.Value, app.f3Slider.Value]);
                Fe = round(app.feSlider.Value);
            end

            % 1. PREMIÈRE FONCTION : Pour l'onglet "Signal"
            function tracerGraphique(app)
                [M, Ai, Fi, Fe] = app.lireParametres();

                % Active le mode debug si la case/bouton est coché
                AFF = double(app.DebugMode);

                % gene_signal gère le debug du signal d'origine via la variable AFF
                app.s = gene_signal(M, Ai, Fi, Fe, AFF);

                t = 0 : 1/Fe : 1 - 1/Fe;
                plot(app.UIAxes, t, app.s);
                xlabel(app.UIAxes, 'Temps (s)');
                ylabel(app.UIAxes, 'Amplitude');
                grid(app.UIAxes, 'on');

            end

            % 2. DEUXIÈME FONCTION : Pour l'onglet "Erreur"
            function tracerGraphiqueErreur(app)
                [~, Ai, Fi, Fe] = app.lireParametres();

                % Génération ou réutilisation du signal d'origine
                if isempty(app.s)
                    app.tracerGraphique();
                end
                s = app.s;
                t = 0 : 1/Fe : 1 - 1/Fe;

                % Choix du type de déformation (numérotation de deform_signal)
			if app.choixdeladformationButtonGroup.SelectedObject == app.linaireButton
				selectedRadio = app.dformationlinaireButtonGroup.SelectedObject;

				switch selectedRadio.Text
					case 'OFFSET'
						choix = 1;
						P1 = 1;                    % Pas de gain (gain unité)
						P0 = app.OFFSETSlider.Value;

					case 'Gain'
						choix = 2;
						P1 = app.GainSlider.Value;
						P0 = 0;                    % Pas de décalage OFFSET

					case 'Gain + OFFSET'
						choix = 3;
						P1 = app.GainSlider.Value;
						P0 = app.OFFSETSlider.Value;

					case 'OFFSET + Gain'
						choix = 4;
						P1 = app.GainSlider.Value;
						P0 = app.OFFSETSlider.Value;

					otherwise
						choix = 0;
						P1 = 1;
						P0 = 0;
				end
			else
				% Modèles non linéaires de deform_signal :
				% 5 : sd = P0 * exp(P1 * s)   6 : sd = P0 + P1 * sign(s) .* log(1 + |s|)
				P0 = app.P0Slider.Value;
				P1 = app.P1Slider.Value;

				selectedRadio = app.dformationnonlinaireButtonGroup.SelectedObject;
				switch selectedRadio.Text
					case 'exponentielle'
						choix = 5;
					case 'logarithmique'
						choix = 6;
					otherwise
						choix = 0;
				end
			end

                % Enregistrement explicite du signal déformé dans app.sd
                app.sd = deform_signal(s, choix, P0, P1);
                sd = app.sd;

                % Affichage indépendant en mode Debug pour la déformation
                if app.DebugMode
                    figure('Name', 'Debug - Signal Déformé');
                    plot(t, sd, '-r');
                    xlabel('Temps (s)');
                    ylabel('Amplitude');
                    title('Signal Déformé (Debug)');
                    grid on;
                end

                % Affichage indépendant en mode Debug pour les composantes f1, f2, f3
                if app.DebugMode
                    % Calcul des signaux élémentaires
                    s1 = Ai(1) * sin(2 * pi * Fi(1) * t);
                    s2 = Ai(2) * sin(2 * pi * Fi(2) * t);
                    s3 = Ai(3) * sin(2 * pi * Fi(3) * t);
                    figure('Name', 'Debug - Composantes f1, f2, f3');

                    subplot(3, 1, 1);
                    plot(t, s1, 'b');
                    ylabel('Amplitude');
                    title(['Composante f1 = ', num2str(Fi(1)), ' Hz']);
                    grid on;
                    subplot(3, 1, 2);
                    plot(t, s2, 'g');
                    ylabel('Amplitude');
                    title(['Composante f2 = ', num2str(Fi(2)), ' Hz']);
                    grid on;
                    subplot(3, 1, 3);
                    plot(t, s3, 'm');
                    xlabel('Temps (s)');
                    ylabel('Amplitude');
                    title(['Composante f3 = ', num2str(Fi(3)), ' Hz']);
                    grid on;
                end

                % Tracé sur l'axe de la page Erreur
                plot(app.UIAxes2, t, s, '--b', t, sd, '-r');
                xlabel(app.UIAxes2, 'Temps (s)');
                ylabel(app.UIAxes2, 'Amplitude');
                legend(app.UIAxes2, 'Original', 'Déformé');
                grid(app.UIAxes2, 'on');
            end

            % Spectre du signal et fréquence fondamentale (raie dominante hors 0 Hz)
            function tracerGraphiqueFFT(app)
                [M, Ai, Fi, Fe] = app.lireParametres();
                s = gene_signal(M, Ai, Fi, Fe, 0);

                N  = length(s);
                N2 = floor(N/2);
                S  = abs(fft(s)) / N;
                S  = S(1:N2);
                f  = (0:N2-1) * Fe / N;

                stem(app.UIAxes3, f, S);
                grid(app.UIAxes3, 'on');
                xlabel(app.UIAxes3, 'Fréquence (Hz)');
                ylabel(app.UIAxes3, '|S(f)|');
                title(app.UIAxes3, 'Spectre du signal');

                f_fond = 0;
                if N2 > 1
                    [~, idx] = max(S(2:end)); % On saute la composante continue
                    f_fond = f(idx + 1);
                end

                % Affichage de la fréquence fondamentale dans le champ texte
                app.FrquencefondamentaleEditField.Value = f_fond;
            end

            function updateSliderStates(app)
				% 1. Si on est en déformation linéaire
				if app.choixdeladformationButtonGroup.SelectedObject == app.linaireButton
					selectedRadio = app.dformationlinaireButtonGroup.SelectedObject;

					% Réglage des sliders non-linéaires (toujours éteints)
					app.P0Slider.Enable = 'off';
					app.P1Slider.Enable = 'off';

					% Réglage des sliders linéaires selon le bouton radio sélectionné
					switch selectedRadio.Text
						case 'Gain'
							app.GainSlider.Enable = 'on';
							app.OFFSETSlider.Enable = 'off';

						case 'OFFSET'
							app.GainSlider.Enable = 'off';
							app.OFFSETSlider.Enable = 'on';

						case {'Gain + OFFSET', 'OFFSET + Gain'}
							app.GainSlider.Enable = 'on';
							app.OFFSETSlider.Enable = 'on';
					end

				% 2. Si on est en déformation non-linéaire
				else
                    % Réglage des sliders linéaires (toujours éteints)
                    app.GainSlider.Enable = 'off';
                    app.OFFSETSlider.Enable = 'off';

                    % Activation des deux sliders P0 et P1
                    app.P0Slider.Enable = 'on';
                    app.P1Slider.Enable = 'on';
				end
            end

            % Estimation et correction : chaque correcteur reçoit (P0, P1) dans
            % l'ordre de deform_signal et renvoie ses estimations dans le même ordre
            function tracerGraphiqueEstimation(app)
				[M, Ai, Fi, fe] = app.lireParametres();

				% Vérification du choix du menu déroulant
				value = app.TypedformationDropDown.Value;

				try
					switch value
						case 'OFFSET'
							[~, ~, ~, P0_m] = correcteOFFSET(M, Ai, Fi, fe, ...
								app.OFFSETSlider.Value, 1, app.UIAxes5, app.UIAxes5_2);
							P1_m = 1; % Pas de gain appliqué

						case 'GAIN'
							[~, ~, ~, P1_m] = correcteGAIN(M, Ai, Fi, fe, ...
								0, app.GainSlider.Value, app.UIAxes5, app.UIAxes5_2);
							P0_m = 0; % Pas d'offset appliqué

						case 'GAIN + OFFSET'
							[~, ~, ~, P1_m, P0_m] = correcteGAIN_OFFSET(M, Ai, Fi, fe, ...
								app.OFFSETSlider.Value, app.GainSlider.Value, app.UIAxes5, app.UIAxes5_2);

						case 'OFFSET + GAIN'
							[~, ~, ~, P1_m, P0_m] = correcteOFFSET_GAIN(M, Ai, Fi, fe, ...
								app.OFFSETSlider.Value, app.GainSlider.Value, app.UIAxes5, app.UIAxes5_2);

						case 'exponentielle'
							[~, ~, ~, P0_m, P1_m] = correcteExponentielle(M, Ai, Fi, fe, ...
								app.P0Slider.Value, app.P1Slider.Value, app.UIAxes5, app.UIAxes5_2);

						case 'logarithmique'
							[~, ~, ~, P0_m, P1_m] = correcteLogarithmique(M, Ai, Fi, fe, ...
								app.P0Slider.Value, app.P1Slider.Value, app.UIAxes5, app.UIAxes5_2);
					end
				catch ME
					% Gain nul, P0 nul ou signal sans harmonique : erreur explicite des correcteurs
					uialert(app.UIFigure, ME.message, 'Estimation impossible', 'Icon', 'error');
					return;
				end

				% Mise à jour des EditFields de l'IHM
				app.P0estimeEditField.Value = P0_m;
				app.P1estimeEditField.Value = P1_m;
			end
    end


    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app)
            % Afficher le panneau linéaire directement au lancement
            app.linairePanel.Visible = 'on';
            app.NonlinairePanel.Visible = 'off';
            app.choixdeladformationButtonGroup.SelectedObject = app.linaireButton;

            % Bloque/Active les bons sliders dès l'ouverture :
            app.updateSliderStates();

            % Premiers tracés avec les valeurs par défaut
            app.tracerGraphique();
            app.tracerGraphiqueFFT();
        end

        % Value changed function: A1Slider, A2Slider, A3Slider, MSlider,
        % ...and 4 other components
        function MSliderValueChanged(app, event)
            app.tracerGraphique();
            app.tracerGraphiqueFFT();
        end

        % Selection changed function: choixdeladformationButtonGroup
        function choixdeladformationButtonGroupSelectionChanged(app, event)
            selectedButton = event.NewValue;
                % On compare directement l'objet bouton sélectionné
            if selectedButton == app.linaireButton
                app.linairePanel.Visible = 'on';
                app.NonlinairePanel.Visible = 'off';
            elseif selectedButton == app.nonlinaireButton
                app.linairePanel.Visible = 'off';
                app.NonlinairePanel.Visible = 'on';
            end
            app.updateSliderStates();      % Active / grise les sliders correspondants
            % Re-tracer le graphique avec les nouveaux paramètres
            app.tracerGraphiqueErreur();
        end

        % Value changed function: GainSlider
        function GainSliderValueChanged(app, event)
            app.tracerGraphiqueErreur();
        end

        % Value changed function: OFFSETSlider
        function OFFSETSliderValueChanged(app, event)
            app.tracerGraphiqueErreur();
        end

        % Value changed function: P1Slider
        function P1SliderValueChanged(app, event)
            app.tracerGraphiqueErreur();
        end

        % Value changed function: P0Slider
        function P0SliderValueChanged(app, event)
            app.tracerGraphiqueErreur();
        end

        % Selection changed function: dformationlinaireButtonGroup
        function dformationlinaireButtonGroupSelectionChanged(app, event)
            app.updateSliderStates();
            app.tracerGraphiqueErreur();
        end

        % Selection changed function: dformationnonlinaireButtonGroup
        function dformationnonlinaireButtonGroupSelectionChanged(app, event)
            app.tracerGraphiqueErreur();
        end

        % Value changed function: DebugButton
        function DebugButtonValueChanged(app, event)
            app.DebugMode = app.DebugButton.Value;

            % Mise à jour des graphiques
            app.tracerGraphiqueErreur();
        end

        % Selection change function: TabGroup
        function TabGroupSelectionChanged(app, event)
            selectedTab = app.TabGroup.SelectedTab;

            % Si l'utilisateur clique sur l'onglet Estimation ou Correction
            if selectedTab == app.EstimationTab || selectedTab == app.CorrectionTab
                app.tracerGraphiqueEstimation();
            end
        end

        % Button pushed function: ExporteruncsvButton
        function ExporteruncsvButtonPushed(app, event)
                % 1. Vérifier si le signal déformé existe
				if isempty(app.sd)
					app.tracerGraphiqueErreur(); % Génère app.sd s'il est vide
				end

				if isempty(app.sd)
					uialert(app.UIFigure, 'Aucun signal déformé à exporter.', 'Erreur', 'Icon', 'error');
					return;
				end

				% 2. Ouvrir la boîte de dialogue pour enregistrer le fichier CSV
				[filename, pathname] = uiputfile('*.csv', 'Enregistrer le signal déformé', 'signal_deforme.csv');

				% 3. Si l'utilisateur a validé l'emplacement
				if ischar(filename) && ischar(pathname)
					fullpath = fullfile(pathname, filename);

					% Récupération de l'axe du temps
					[~, ~, ~, Fe] = app.lireParametres();
					N = length(app.sd);
					t = (0 : N-1)' / Fe;

					% Mise en colonne du signal
					sd_col = app.sd(:);

					% Création du tableau de données (Temps et Signal Déformé)
					T = table(t, sd_col, 'VariableNames', {'Temps_s', 'Signal_Deforme'});

					% Écriture dans le fichier CSV
					try
						writetable(T, fullpath);
						uialert(app.UIFigure, ['Fichier exporté avec succès : ', filename], ...
							'Succès', 'Icon', 'success');
					catch ME
						uialert(app.UIFigure, ['Erreur lors de l''exportation : ', ME.message], ...
							'Erreur', 'Icon', 'error');
					end
				end
        end

        % Value changed function: TypedformationDropDown
        function TypedformationDropDownValueChanged(app, event)
            app.tracerGraphiqueEstimation();
        end

        % Button pushed function: ExporterenPDFButton
        function ExporterenPDFButtonPushed(app, event)
            [filename, pathname] = uiputfile('*.pdf', 'Enregistrer le rapport PDF', 'Rapport_analyse.pdf');
            if isequal(filename, 0) || isequal(pathname, 0)
                return;
            end
            fullpath = fullfile(pathname, filename);

            % Figure temporaire A4
            fig = figure('Visible', 'off', 'Units', 'centimeters', 'Position', [0 0 21 29.7]);

            % Organisation propre avec TiledLayout
            t = tiledlayout(fig, 4, 1, 'Padding', 'compact', 'TileSpacing', 'compact');

            % Titre général du rapport (positionné proprement en haut)
            title(t, sprintf('RAPPORT D''ANALYSE ET CORRECTION DU SIGNAL\nFe: %.1f Hz | M: %.2f | P0: %.2f | P1: %.2f', ...
                round(app.feSlider.Value), app.MSlider.Value, app.P0estimeEditField.Value, app.P1estimeEditField.Value), ...
                'FontSize', 12, 'FontWeight', 'bold');

            % 1. Signal Original
            ax1 = nexttile(t);
            copyobj(app.UIAxes.Children, ax1);
            title(ax1, 'Signal Original');
            xlabel(ax1, 'Temps (s)'); ylabel(ax1, 'Amplitude'); grid(ax1, 'on');

            % 2. Signal Déformé / Erreur
            ax2 = nexttile(t);
            copyobj(app.UIAxes2.Children, ax2);
            title(ax2, 'Signal Déformé / Erreur');
            xlabel(ax2, 'Temps (s)'); ylabel(ax2, 'Amplitude'); grid(ax2, 'on');

            % 3. Spectre FFT
            ax3 = nexttile(t);
            copyobj(app.UIAxes3.Children, ax3);
            title(ax3, sprintf('Spectre FFT (Fondamentale: %.2f Hz)', app.FrquencefondamentaleEditField.Value));
            xlabel(ax3, 'Fréquence (Hz)'); ylabel(ax3, '|S(f)|'); grid(ax3, 'on');

            % 4. Signal Corrigé
            ax4 = nexttile(t);
            copyobj(app.UIAxes5_2.Children, ax4);
            title(ax4, 'Signal Corrigé');
            xlabel(ax4, 'Temps (s)'); ylabel(ax4, 'Amplitude'); grid(ax4, 'on');

            % Exportation PDF
            try
                exportgraphics(fig, fullpath, 'ContentType', 'vector');
                close(fig);
                uialert(app.UIFigure, ['PDF généré avec succès : ', filename], 'Succès', 'Icon', 'success');
            catch ME
                close(fig);
                uialert(app.UIFigure, ['Erreur lors de la génération PDF : ', ME.message], 'Erreur', 'Icon', 'error');
            end
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.Position = [100 100 640 480];
            app.UIFigure.Name = 'Chaîne de mesure - FFT';

            % Create TabGroup
            app.TabGroup = uitabgroup(app.UIFigure);
            app.TabGroup.SelectionChangedFcn = createCallbackFcn(app, @TabGroupSelectionChanged, true);
            app.TabGroup.Position = [1 1 640 480];

            % Create AccueilTab
            app.AccueilTab = uitab(app.TabGroup);
            app.AccueilTab.Title = 'Accueil';
            app.AccueilTab.BackgroundColor = [0.8196 0.8196 0.7882];

            % Create TitreLabel
            app.TitreLabel = uilabel(app.AccueilTab);
            app.TitreLabel.HorizontalAlignment = 'center';
            app.TitreLabel.FontSize = 28;
            app.TitreLabel.FontWeight = 'bold';
            app.TitreLabel.Position = [20 300 600 110];
            app.TitreLabel.Text = {'Chaîne de mesure'; 'Estimation et correction par FFT'};

            % Create DescriptionLabel
            app.DescriptionLabel = uilabel(app.AccueilTab);
            app.DescriptionLabel.HorizontalAlignment = 'center';
            app.DescriptionLabel.FontSize = 16;
            app.DescriptionLabel.Position = [20 120 600 150];
            app.DescriptionLabel.Text = {'ECUE 325 - EPISEN'; ''; ...
                'Signal : réglage de M, Ai, Fi et fe'; ...
                'Erreur : déformation linéaire ou non linéaire'; ...
                'FFT, Estimation, Correction : analyse et inversion'; ...
                'Option : mode debug, export CSV et PDF'};

            % Create SignalTab
            app.SignalTab = uitab(app.TabGroup);
            app.SignalTab.Title = 'Signal';
            app.SignalTab.BackgroundColor = [0.8196 0.8196 0.7882];

            % Create UIAxes
            app.UIAxes = uiaxes(app.SignalTab);
            title(app.UIAxes, 'Courbe du signal')
            xlabel(app.UIAxes, 'Temps (s)')
            ylabel(app.UIAxes, 'Amplitude')
            zlabel(app.UIAxes, 'Z')
            app.UIAxes.Position = [252 63 378 309];

            % Create MSliderLabel
            app.MSliderLabel = uilabel(app.SignalTab);
            app.MSliderLabel.HorizontalAlignment = 'right';
            app.MSliderLabel.FontWeight = 'bold';
            app.MSliderLabel.Position = [22 348 25 22];
            app.MSliderLabel.Text = 'M';

            % Create MSlider
            app.MSlider = uislider(app.SignalTab);
            app.MSlider.Limits = [-5 5];
            app.MSlider.ValueChangedFcn = createCallbackFcn(app, @MSliderValueChanged, true);
            app.MSlider.FontWeight = 'bold';
            app.MSlider.Position = [69 357 150 3];
            app.MSlider.Value = 2;

            % Create A1SliderLabel
            app.A1SliderLabel = uilabel(app.SignalTab);
            app.A1SliderLabel.HorizontalAlignment = 'right';
            app.A1SliderLabel.FontWeight = 'bold';
            app.A1SliderLabel.Position = [22 299 25 22];
            app.A1SliderLabel.Text = 'A1';

            % Create A1Slider
            app.A1Slider = uislider(app.SignalTab);
            app.A1Slider.Limits = [0 10];
            app.A1Slider.ValueChangedFcn = createCallbackFcn(app, @MSliderValueChanged, true);
            app.A1Slider.FontWeight = 'bold';
            app.A1Slider.Position = [69 308 150 3];
            app.A1Slider.Value = 5;

            % Create A2SliderLabel
            app.A2SliderLabel = uilabel(app.SignalTab);
            app.A2SliderLabel.HorizontalAlignment = 'right';
            app.A2SliderLabel.FontWeight = 'bold';
            app.A2SliderLabel.Position = [22 253 25 22];
            app.A2SliderLabel.Text = 'A2';

            % Create A2Slider
            app.A2Slider = uislider(app.SignalTab);
            app.A2Slider.Limits = [0 10];
            app.A2Slider.ValueChangedFcn = createCallbackFcn(app, @MSliderValueChanged, true);
            app.A2Slider.FontWeight = 'bold';
            app.A2Slider.Position = [69 262 150 3];
            app.A2Slider.Value = 3;

            % Create A3SliderLabel
            app.A3SliderLabel = uilabel(app.SignalTab);
            app.A3SliderLabel.HorizontalAlignment = 'right';
            app.A3SliderLabel.FontWeight = 'bold';
            app.A3SliderLabel.Position = [22 208 25 22];
            app.A3SliderLabel.Text = 'A3';

            % Create A3Slider
            app.A3Slider = uislider(app.SignalTab);
            app.A3Slider.Limits = [0 10];
            app.A3Slider.ValueChangedFcn = createCallbackFcn(app, @MSliderValueChanged, true);
            app.A3Slider.FontWeight = 'bold';
            app.A3Slider.Position = [69 217 150 3];
            app.A3Slider.Value = 2;

            % Create f1SliderLabel
            app.f1SliderLabel = uilabel(app.SignalTab);
            app.f1SliderLabel.HorizontalAlignment = 'right';
            app.f1SliderLabel.FontWeight = 'bold';
            app.f1SliderLabel.Position = [22 165 25 22];
            app.f1SliderLabel.Text = 'f1';

            % Create f1Slider
            app.f1Slider = uislider(app.SignalTab);
            app.f1Slider.Limits = [1 10];
            app.f1Slider.ValueChangedFcn = createCallbackFcn(app, @MSliderValueChanged, true);
            app.f1Slider.FontWeight = 'bold';
            app.f1Slider.Position = [69 174 150 3];
            app.f1Slider.Value = 4;

            % Create f2SliderLabel
            app.f2SliderLabel = uilabel(app.SignalTab);
            app.f2SliderLabel.HorizontalAlignment = 'right';
            app.f2SliderLabel.FontWeight = 'bold';
            app.f2SliderLabel.Position = [22 123 25 22];
            app.f2SliderLabel.Text = 'f2';

            % Create f2Slider
            app.f2Slider = uislider(app.SignalTab);
            app.f2Slider.Limits = [1 10];
            app.f2Slider.ValueChangedFcn = createCallbackFcn(app, @MSliderValueChanged, true);
            app.f2Slider.FontWeight = 'bold';
            app.f2Slider.Position = [69 132 150 3];
            app.f2Slider.Value = 6;

            % Create f3SliderLabel
            app.f3SliderLabel = uilabel(app.SignalTab);
            app.f3SliderLabel.HorizontalAlignment = 'right';
            app.f3SliderLabel.FontWeight = 'bold';
            app.f3SliderLabel.Position = [22 81 25 22];
            app.f3SliderLabel.Text = 'f3';

            % Create f3Slider
            app.f3Slider = uislider(app.SignalTab);
            app.f3Slider.Limits = [1 10];
            app.f3Slider.ValueChangedFcn = createCallbackFcn(app, @MSliderValueChanged, true);
            app.f3Slider.FontWeight = 'bold';
            app.f3Slider.Position = [69 90 150 3];
            app.f3Slider.Value = 7;

            % Create feSliderLabel
            app.feSliderLabel = uilabel(app.SignalTab);
            app.feSliderLabel.HorizontalAlignment = 'right';
            app.feSliderLabel.FontWeight = 'bold';
            app.feSliderLabel.Position = [22 39 25 22];
            app.feSliderLabel.Text = 'fe';

            % Create feSlider (fe > 2 * max(Fi) = 20 Hz)
            app.feSlider = uislider(app.SignalTab);
            app.feSlider.Limits = [25 200];
            app.feSlider.ValueChangedFcn = createCallbackFcn(app, @MSliderValueChanged, true);
            app.feSlider.FontWeight = 'bold';
            app.feSlider.Position = [69 48 150 3];
            app.feSlider.Value = 100;

            % Create ParamtreLabel
            app.ParamtreLabel = uilabel(app.SignalTab);
            app.ParamtreLabel.FontSize = 24;
            app.ParamtreLabel.FontWeight = 'bold';
            app.ParamtreLabel.Position = [34 381 137 40];
            app.ParamtreLabel.Text = 'Paramètres :';

            % Create MenusignalLabel
            app.MenusignalLabel = uilabel(app.SignalTab);
            app.MenusignalLabel.FontSize = 36;
            app.MenusignalLabel.FontWeight = 'bold';
            app.MenusignalLabel.Position = [227 398 214 47];
            app.MenusignalLabel.Text = 'Menu signal';

            % Create ErreurTab
            app.ErreurTab = uitab(app.TabGroup);
            app.ErreurTab.Title = 'Erreur';
            app.ErreurTab.BackgroundColor = [0.8196 0.8196 0.7882];

            % Create UIAxes2
            app.UIAxes2 = uiaxes(app.ErreurTab);
            title(app.UIAxes2, 'Erreur')
            xlabel(app.UIAxes2, 'Temps (s)')
            ylabel(app.UIAxes2, 'Amplitude')
            zlabel(app.UIAxes2, 'Z')
            app.UIAxes2.Position = [269 80 361 262];

            % Create MenuErreurLabel
            app.MenuErreurLabel = uilabel(app.ErreurTab);
            app.MenuErreurLabel.FontSize = 36;
            app.MenuErreurLabel.FontWeight = 'bold';
            app.MenuErreurLabel.Position = [219 404 218 47];
            app.MenuErreurLabel.Text = 'Menu Erreur';

            % Create ParamtreLabel_2
            app.ParamtreLabel_2 = uilabel(app.ErreurTab);
            app.ParamtreLabel_2.FontSize = 24;
            app.ParamtreLabel_2.FontWeight = 'bold';
            app.ParamtreLabel_2.Position = [34 381 137 40];
            app.ParamtreLabel_2.Text = 'Paramètres :';

            % Create choixdeladformationButtonGroup
            app.choixdeladformationButtonGroup = uibuttongroup(app.ErreurTab);
            app.choixdeladformationButtonGroup.SelectionChangedFcn = createCallbackFcn(app, @choixdeladformationButtonGroupSelectionChanged, true);
            app.choixdeladformationButtonGroup.Title = 'choix de la déformation';
            app.choixdeladformationButtonGroup.BackgroundColor = [0.8196 0.8196 0.7882];
            app.choixdeladformationButtonGroup.FontWeight = 'bold';
            app.choixdeladformationButtonGroup.Position = [34 278 149 82];

            % Create linaireButton
            app.linaireButton = uitogglebutton(app.choixdeladformationButtonGroup);
            app.linaireButton.Text = ' linéaire';
            app.linaireButton.BackgroundColor = [0.8196 0.8196 0.7882];
            app.linaireButton.FontWeight = 'bold';
            app.linaireButton.Position = [19 28 100 23];
            app.linaireButton.Value = true;

            % Create nonlinaireButton
            app.nonlinaireButton = uitogglebutton(app.choixdeladformationButtonGroup);
            app.nonlinaireButton.Text = 'non linéaire';
            app.nonlinaireButton.FontWeight = 'bold';
            app.nonlinaireButton.Position = [19 6 100 23];

            % Create linairePanel
            app.linairePanel = uipanel(app.ErreurTab);
            app.linairePanel.Title = 'linéaire';
            app.linairePanel.Visible = 'off';
            app.linairePanel.BackgroundColor = [0.8196 0.8196 0.7882];
            app.linairePanel.Position = [11 18 260 245];

            % Create GainSliderLabel
            app.GainSliderLabel = uilabel(app.linairePanel);
            app.GainSliderLabel.HorizontalAlignment = 'right';
            app.GainSliderLabel.Position = [8 75 51 22];
            app.GainSliderLabel.Text = 'Gain P1';

            % Create GainSlider
            app.GainSlider = uislider(app.linairePanel);
            app.GainSlider.Limits = [0.1 10];
            app.GainSlider.ValueChangedFcn = createCallbackFcn(app, @GainSliderValueChanged, true);
            app.GainSlider.Position = [82 85 147 3];
            app.GainSlider.Value = 1;

            % Create dformationlinaireButtonGroup
            app.dformationlinaireButtonGroup = uibuttongroup(app.linairePanel);
            app.dformationlinaireButtonGroup.SelectionChangedFcn = createCallbackFcn(app, @dformationlinaireButtonGroupSelectionChanged, true);
            app.dformationlinaireButtonGroup.Title = 'déformation linéaire';
            app.dformationlinaireButtonGroup.Position = [47 99 123 115];

            % Create GainButton
            app.GainButton = uiradiobutton(app.dformationlinaireButtonGroup);
            app.GainButton.Text = 'Gain';
            app.GainButton.Position = [11 69 58 22];
            app.GainButton.Value = true;

            % Create OFFSETButton
            app.OFFSETButton = uiradiobutton(app.dformationlinaireButtonGroup);
            app.OFFSETButton.Text = 'OFFSET';
            app.OFFSETButton.Position = [11 47 70 22];

            % Create GainOFFSETButton
            app.GainOFFSETButton = uiradiobutton(app.dformationlinaireButtonGroup);
            app.GainOFFSETButton.Text = 'Gain + OFFSET';
            app.GainOFFSETButton.Position = [11 25 109 22];

            % Create OFFSETGainButton
            app.OFFSETGainButton = uiradiobutton(app.dformationlinaireButtonGroup);
            app.OFFSETGainButton.Text = 'OFFSET + Gain';
            app.OFFSETGainButton.Position = [11 3 109 22];

            % Create OFFSETSliderLabel
            app.OFFSETSliderLabel = uilabel(app.linairePanel);
            app.OFFSETSliderLabel.HorizontalAlignment = 'right';
            app.OFFSETSliderLabel.Position = [2 32 73 22];
            app.OFFSETSliderLabel.Text = 'OFFSET P0';

            % Create OFFSETSlider
            app.OFFSETSlider = uislider(app.linairePanel);
            app.OFFSETSlider.Limits = [-50 50];
            app.OFFSETSlider.ValueChangedFcn = createCallbackFcn(app, @OFFSETSliderValueChanged, true);
            app.OFFSETSlider.Position = [83 41 150 3];

            % Create NonlinairePanel
            app.NonlinairePanel = uipanel(app.ErreurTab);
            app.NonlinairePanel.Title = 'Non linéaire';
            app.NonlinairePanel.Visible = 'off';
            app.NonlinairePanel.BackgroundColor = [0.8196 0.8196 0.7882];
            app.NonlinairePanel.Position = [10 39 260 221];

            % Create P0SliderLabel
            app.P0SliderLabel = uilabel(app.NonlinairePanel);
            app.P0SliderLabel.HorizontalAlignment = 'right';
            app.P0SliderLabel.Position = [33 30 25 22];
            app.P0SliderLabel.Text = 'P0';

            % Create P0Slider
            app.P0Slider = uislider(app.NonlinairePanel);
            app.P0Slider.Limits = [-10 10];
            app.P0Slider.ValueChangedFcn = createCallbackFcn(app, @P0SliderValueChanged, true);
            app.P0Slider.Position = [80 39 150 3];
            app.P0Slider.Value = 1;

            % Create P1SliderLabel
            app.P1SliderLabel = uilabel(app.NonlinairePanel);
            app.P1SliderLabel.HorizontalAlignment = 'right';
            app.P1SliderLabel.Position = [33 77 25 22];
            app.P1SliderLabel.Text = 'P1';

            % Create P1Slider
            app.P1Slider = uislider(app.NonlinairePanel);
            app.P1Slider.Limits = [0.1 1.5];
            app.P1Slider.ValueChangedFcn = createCallbackFcn(app, @P1SliderValueChanged, true);
            app.P1Slider.Position = [80 86 150 3];
            app.P1Slider.Value = 1;

            % Create dformationnonlinaireButtonGroup
            app.dformationnonlinaireButtonGroup = uibuttongroup(app.NonlinairePanel);
            app.dformationnonlinaireButtonGroup.SelectionChangedFcn = createCallbackFcn(app, @dformationnonlinaireButtonGroupSelectionChanged, true);
            app.dformationnonlinaireButtonGroup.Title = 'déformation non linéaire';
            app.dformationnonlinaireButtonGroup.FontWeight = 'bold';
            app.dformationnonlinaireButtonGroup.Position = [80 113 142 77];

            % Create exponentielleButton
            app.exponentielleButton = uiradiobutton(app.dformationnonlinaireButtonGroup);
            app.exponentielleButton.Text = 'exponentielle';
            app.exponentielleButton.Position = [11 31 93 22];
            app.exponentielleButton.Value = true;

            % Create logarithmiqueButton
            app.logarithmiqueButton = uiradiobutton(app.dformationnonlinaireButtonGroup);
            app.logarithmiqueButton.Text = 'logarithmique';
            app.logarithmiqueButton.Position = [11 9 94 22];

            % Create FFTTab
            app.FFTTab = uitab(app.TabGroup);
            app.FFTTab.Title = 'FFT';
            app.FFTTab.BackgroundColor = [0.8196 0.8196 0.7882];

            % Create UIAxes3
            app.UIAxes3 = uiaxes(app.FFTTab);
            title(app.UIAxes3, 'Spectre du signal')
            xlabel(app.UIAxes3, 'Fréquence (Hz)')
            ylabel(app.UIAxes3, '|S(f)|')
            zlabel(app.UIAxes3, 'Z')
            app.UIAxes3.FontWeight = 'bold';
            app.UIAxes3.Position = [1 3 638 325];

            % Create MenuFFTLabel
            app.MenuFFTLabel = uilabel(app.FFTTab);
            app.MenuFFTLabel.FontSize = 36;
            app.MenuFFTLabel.FontWeight = 'bold';
            app.MenuFFTLabel.Position = [232 398 175 47];
            app.MenuFFTLabel.Text = 'Menu FFT';

            % Create FrquencefondamentaleEditFieldLabel
            app.FrquencefondamentaleEditFieldLabel = uilabel(app.FFTTab);
            app.FrquencefondamentaleEditFieldLabel.HorizontalAlignment = 'right';
            app.FrquencefondamentaleEditFieldLabel.FontWeight = 'bold';
            app.FrquencefondamentaleEditFieldLabel.Position = [30 327 147 22];
            app.FrquencefondamentaleEditFieldLabel.Text = 'Fréquence fondamentale';

            % Create FrquencefondamentaleEditField
            app.FrquencefondamentaleEditField = uieditfield(app.FFTTab, 'numeric');
            app.FrquencefondamentaleEditField.Editable = 'off';
            app.FrquencefondamentaleEditField.Position = [192 327 100 22];

            % Create EstimationTab
            app.EstimationTab = uitab(app.TabGroup);
            app.EstimationTab.Title = 'Estimation';
            app.EstimationTab.BackgroundColor = [0.8196 0.8196 0.7882];

            % Create UIAxes5
            app.UIAxes5 = uiaxes(app.EstimationTab);
            title(app.UIAxes5, 'Spectre de la déformation')
            xlabel(app.UIAxes5, 'Fréquence (Hz)')
            ylabel(app.UIAxes5, '|S(f)|')
            zlabel(app.UIAxes5, 'Z')
            app.UIAxes5.Position = [14 18 509 297];

            % Create MenuEstimationLabel
            app.MenuEstimationLabel = uilabel(app.EstimationTab);
            app.MenuEstimationLabel.FontSize = 36;
            app.MenuEstimationLabel.FontWeight = 'bold';
            app.MenuEstimationLabel.Position = [179 395 297 47];
            app.MenuEstimationLabel.Text = 'Menu Estimation';

            % Create TypedformationDropDownLabel
            app.TypedformationDropDownLabel = uilabel(app.EstimationTab);
            app.TypedformationDropDownLabel.HorizontalAlignment = 'right';
            app.TypedformationDropDownLabel.Position = [147 336 98 22];
            app.TypedformationDropDownLabel.Text = 'Type déformation';

            % Create TypedformationDropDown
            app.TypedformationDropDown = uidropdown(app.EstimationTab);
            app.TypedformationDropDown.Items = {'OFFSET', 'GAIN', 'GAIN + OFFSET', 'OFFSET + GAIN', 'exponentielle', 'logarithmique'};
            app.TypedformationDropDown.ValueChangedFcn = createCallbackFcn(app, @TypedformationDropDownValueChanged, true);
            app.TypedformationDropDown.Position = [260 336 100 22];
            app.TypedformationDropDown.Value = 'OFFSET';

            % Create P0estimeEditFieldLabel
            app.P0estimeEditFieldLabel = uilabel(app.EstimationTab);
            app.P0estimeEditFieldLabel.HorizontalAlignment = 'right';
            app.P0estimeEditFieldLabel.FontWeight = 'bold';
            app.P0estimeEditFieldLabel.Position = [527 229 98 22];
            app.P0estimeEditFieldLabel.Text = 'P0 estimé';

            % Create P0estimeEditField
            app.P0estimeEditField = uieditfield(app.EstimationTab, 'numeric');
            app.P0estimeEditField.Editable = 'off';
            app.P0estimeEditField.Position = [543 200 65 22];

            % Create P1estimeEditFieldLabel
            app.P1estimeEditFieldLabel = uilabel(app.EstimationTab);
            app.P1estimeEditFieldLabel.HorizontalAlignment = 'right';
            app.P1estimeEditFieldLabel.FontWeight = 'bold';
            app.P1estimeEditFieldLabel.Position = [535 161 81 22];
            app.P1estimeEditFieldLabel.Text = 'P1 estimé';

            % Create P1estimeEditField
            app.P1estimeEditField = uieditfield(app.EstimationTab, 'numeric');
            app.P1estimeEditField.Editable = 'off';
            app.P1estimeEditField.Position = [543 131 65 22];

            % Create CorrectionTab
            app.CorrectionTab = uitab(app.TabGroup);
            app.CorrectionTab.Title = 'Correction';
            app.CorrectionTab.BackgroundColor = [0.8196 0.8196 0.7882];

            % Create UIAxes5_2
            app.UIAxes5_2 = uiaxes(app.CorrectionTab);
            title(app.UIAxes5_2, 'Signal corrigé')
            xlabel(app.UIAxes5_2, 'Temps (s)')
            ylabel(app.UIAxes5_2, 'Amplitude')
            zlabel(app.UIAxes5_2, 'Z')
            app.UIAxes5_2.Position = [11 21 614 321];

            % Create MenuCorrectionLabel
            app.MenuCorrectionLabel = uilabel(app.CorrectionTab);
            app.MenuCorrectionLabel.FontSize = 36;
            app.MenuCorrectionLabel.FontWeight = 'bold';
            app.MenuCorrectionLabel.Position = [179 395 295 47];
            app.MenuCorrectionLabel.Text = 'Menu Correction';

            % Create OptionTab
            app.OptionTab = uitab(app.TabGroup);
            app.OptionTab.Title = 'Option';
            app.OptionTab.BackgroundColor = [0.8196 0.8196 0.7882];

            % Create OptionsuprautilisateurLabel
            app.OptionsuprautilisateurLabel = uilabel(app.OptionTab);
            app.OptionsuprautilisateurLabel.FontSize = 18;
            app.OptionsuprautilisateurLabel.FontWeight = 'bold';
            app.OptionsuprautilisateurLabel.Position = [25 362 214 23];
            app.OptionsuprautilisateurLabel.Text = 'Option supra utilisateur ';

            % Create MenuOptionLabel
            app.MenuOptionLabel = uilabel(app.OptionTab);
            app.MenuOptionLabel.FontSize = 36;
            app.MenuOptionLabel.FontWeight = 'bold';
            app.MenuOptionLabel.Position = [207 401 227 47];
            app.MenuOptionLabel.Text = 'Menu Option';

            % Create DebugButton
            app.DebugButton = uibutton(app.OptionTab, 'state');
            app.DebugButton.ValueChangedFcn = createCallbackFcn(app, @DebugButtonValueChanged, true);
            app.DebugButton.Text = 'Mode debug';
            app.DebugButton.Position = [64 325 100 23];

            % Create ExporteruncsvButton
            app.ExporteruncsvButton = uibutton(app.OptionTab, 'push');
            app.ExporteruncsvButton.ButtonPushedFcn = createCallbackFcn(app, @ExporteruncsvButtonPushed, true);
            app.ExporteruncsvButton.Position = [63 250 102 23];
            app.ExporteruncsvButton.Text = 'Exporter un .csv';

            % Create OptiondexportationdefichierLabel
            app.OptiondexportationdefichierLabel = uilabel(app.OptionTab);
            app.OptiondexportationdefichierLabel.FontSize = 18;
            app.OptiondexportationdefichierLabel.FontWeight = 'bold';
            app.OptiondexportationdefichierLabel.Position = [25 286 269 23];
            app.OptiondexportationdefichierLabel.Text = 'Option d''exportation de fichier';

            % Create ExporterenPDFButton
            app.ExporterenPDFButton = uibutton(app.OptionTab, 'push');
            app.ExporterenPDFButton.ButtonPushedFcn = createCallbackFcn(app, @ExporterenPDFButtonPushed, true);
            app.ExporterenPDFButton.Position = [62 206 104 23];
            app.ExporterenPDFButton.Text = 'Exporter en PDF';

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = ihm_code

            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.UIFigure)

            % Execute the startup function
            runStartupFcn(app, @startupFcn)

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.UIFigure)
        end
    end
end
