namespace Documate
{
    partial class MainForm
    {
        /// <summary>
        ///  Required designer variable.
        /// </summary>
        private System.ComponentModel.IContainer components = null;

        /// <summary>
        ///  Clean up any resources being used.
        /// </summary>
        /// <param name="disposing">true if managed resources should be disposed; otherwise, false.</param>
        protected override void Dispose(bool disposing)
        {
            if (disposing && (components != null))
            {
                components.Dispose();
            }
            base.Dispose(disposing);
        }

        #region Windows Form Designer generated code

        /// <summary>
        ///  Required method for Designer support - do not modify
        ///  the contents of this method with the code editor.
        /// </summary>
        private void InitializeComponent()
        {
            MenuStripMain = new MenuStrip();
            MenuItemProgram = new ToolStripMenuItem();
            MenuItemProgramOpenFile = new ToolStripMenuItem();
            MenuItemProgramCloseFile = new ToolStripMenuItem();
            MenuItemProgramNewFile = new ToolStripMenuItem();
            MenuItemProgramSep1 = new ToolStripSeparator();
            MenuItemProgramExit = new ToolStripMenuItem();
            MenuItemOptions = new ToolStripMenuItem();
            MenuItemOptionsOptions = new ToolStripMenuItem();
            MenuItemLanguage = new ToolStripMenuItem();
            MenuItemLanguageEN = new ToolStripMenuItem();
            MenuItemLanguageNL = new ToolStripMenuItem();
            statusStrip1 = new StatusStrip();
            ToolStripStatusLabel1 = new ToolStripStatusLabel();
            ToolStripStatusLabel2 = new ToolStripStatusLabel();
            TabControlMain = new TabControl();
            TabPageReadItems = new TabPage();
            TabPageEditItems = new TabPage();
            MenuStripMain.SuspendLayout();
            statusStrip1.SuspendLayout();
            TabControlMain.SuspendLayout();
            SuspendLayout();
            // 
            // MenuStripMain
            // 
            MenuStripMain.ImageScalingSize = new Size(24, 24);
            MenuStripMain.Items.AddRange(new ToolStripItem[] { MenuItemProgram, MenuItemOptions });
            MenuStripMain.Location = new Point(0, 0);
            MenuStripMain.Name = "MenuStripMain";
            MenuStripMain.Size = new Size(1010, 33);
            MenuStripMain.TabIndex = 0;
            MenuStripMain.Text = "menuStrip1";
            // 
            // MenuItemProgram
            // 
            MenuItemProgram.DropDownItems.AddRange(new ToolStripItem[] { MenuItemProgramOpenFile, MenuItemProgramCloseFile, MenuItemProgramNewFile, MenuItemProgramSep1, MenuItemProgramExit });
            MenuItemProgram.Name = "MenuItemProgram";
            MenuItemProgram.Size = new Size(178, 29);
            MenuItemProgram.Text = "MenuItemProgram";
            // 
            // MenuItemProgramOpenFile
            // 
            MenuItemProgramOpenFile.Name = "MenuItemProgramOpenFile";
            MenuItemProgramOpenFile.ShortcutKeys = Keys.Control | Keys.O;
            MenuItemProgramOpenFile.Size = new Size(401, 34);
            MenuItemProgramOpenFile.Text = "MenuItemProgramOpenFile";
            // 
            // MenuItemProgramCloseFile
            // 
            MenuItemProgramCloseFile.Name = "MenuItemProgramCloseFile";
            MenuItemProgramCloseFile.ShortcutKeys = Keys.Control | Keys.W;
            MenuItemProgramCloseFile.Size = new Size(401, 34);
            MenuItemProgramCloseFile.Text = "MenuItemProgramCloseFile";
            // 
            // MenuItemProgramNewFile
            // 
            MenuItemProgramNewFile.Name = "MenuItemProgramNewFile";
            MenuItemProgramNewFile.ShortcutKeys = Keys.Control | Keys.N;
            MenuItemProgramNewFile.Size = new Size(401, 34);
            MenuItemProgramNewFile.Text = "MenuItemProgramNewFile";
            // 
            // MenuItemProgramSep1
            // 
            MenuItemProgramSep1.Name = "MenuItemProgramSep1";
            MenuItemProgramSep1.Size = new Size(398, 6);
            // 
            // MenuItemProgramExit
            // 
            MenuItemProgramExit.Name = "MenuItemProgramExit";
            MenuItemProgramExit.ShortcutKeys = Keys.Alt | Keys.F4;
            MenuItemProgramExit.Size = new Size(401, 34);
            MenuItemProgramExit.Text = "MenuItemProgramExit";
            // 
            // MenuItemOptions
            // 
            MenuItemOptions.DropDownItems.AddRange(new ToolStripItem[] { MenuItemOptionsOptions, MenuItemLanguage });
            MenuItemOptions.Name = "MenuItemOptions";
            MenuItemOptions.Size = new Size(173, 29);
            MenuItemOptions.Text = "MenuItemOptions";
            // 
            // MenuItemOptionsOptions
            // 
            MenuItemOptionsOptions.Name = "MenuItemOptionsOptions";
            MenuItemOptionsOptions.Size = new Size(323, 34);
            MenuItemOptionsOptions.Text = "MenuItemOptionsOptions";
            // 
            // MenuItemLanguage
            // 
            MenuItemLanguage.DropDownItems.AddRange(new ToolStripItem[] { MenuItemLanguageEN, MenuItemLanguageNL });
            MenuItemLanguage.Name = "MenuItemLanguage";
            MenuItemLanguage.Size = new Size(323, 34);
            MenuItemLanguage.Text = "MenuItemLanguage";
            // 
            // MenuItemLanguageEN
            // 
            MenuItemLanguageEN.Name = "MenuItemLanguageEN";
            MenuItemLanguageEN.Size = new Size(294, 34);
            MenuItemLanguageEN.Text = "MenuItemLanguageEN";
            // 
            // MenuItemLanguageNL
            // 
            MenuItemLanguageNL.Name = "MenuItemLanguageNL";
            MenuItemLanguageNL.Size = new Size(294, 34);
            MenuItemLanguageNL.Text = "MenuItemLanguageNL";
            // 
            // statusStrip1
            // 
            statusStrip1.ImageScalingSize = new Size(24, 24);
            statusStrip1.Items.AddRange(new ToolStripItem[] { ToolStripStatusLabel1, ToolStripStatusLabel2 });
            statusStrip1.Location = new Point(0, 537);
            statusStrip1.Name = "statusStrip1";
            statusStrip1.Size = new Size(1010, 32);
            statusStrip1.TabIndex = 1;
            statusStrip1.Text = "statusStrip1";
            // 
            // ToolStripStatusLabel1
            // 
            ToolStripStatusLabel1.Name = "ToolStripStatusLabel1";
            ToolStripStatusLabel1.Size = new Size(180, 25);
            ToolStripStatusLabel1.Text = "ToolStripStatusLabel1";
            // 
            // ToolStripStatusLabel2
            // 
            ToolStripStatusLabel2.Name = "ToolStripStatusLabel2";
            ToolStripStatusLabel2.Size = new Size(180, 25);
            ToolStripStatusLabel2.Text = "ToolStripStatusLabel2";
            // 
            // TabControlMain
            // 
            TabControlMain.Controls.Add(TabPageReadItems);
            TabControlMain.Controls.Add(TabPageEditItems);
            TabControlMain.Location = new Point(121, 95);
            TabControlMain.Name = "TabControlMain";
            TabControlMain.SelectedIndex = 0;
            TabControlMain.Size = new Size(729, 327);
            TabControlMain.TabIndex = 2;
            // 
            // TabPageReadItems
            // 
            TabPageReadItems.Location = new Point(4, 34);
            TabPageReadItems.Name = "TabPageReadItems";
            TabPageReadItems.Padding = new Padding(3);
            TabPageReadItems.Size = new Size(721, 289);
            TabPageReadItems.TabIndex = 0;
            TabPageReadItems.Text = "TabPageReadItems";
            TabPageReadItems.UseVisualStyleBackColor = true;
            // 
            // TabPageEditItems
            // 
            TabPageEditItems.Location = new Point(4, 34);
            TabPageEditItems.Name = "TabPageEditItems";
            TabPageEditItems.Padding = new Padding(3);
            TabPageEditItems.Size = new Size(721, 289);
            TabPageEditItems.TabIndex = 1;
            TabPageEditItems.Text = "TabPageEditItems";
            TabPageEditItems.UseVisualStyleBackColor = true;
            // 
            // MainForm
            // 
            AutoScaleDimensions = new SizeF(10F, 25F);
            AutoScaleMode = AutoScaleMode.Font;
            ClientSize = new Size(1010, 569);
            Controls.Add(TabControlMain);
            Controls.Add(statusStrip1);
            Controls.Add(MenuStripMain);
            MainMenuStrip = MenuStripMain;
            Name = "MainForm";
            Text = "MainForm";
            MenuStripMain.ResumeLayout(false);
            MenuStripMain.PerformLayout();
            statusStrip1.ResumeLayout(false);
            statusStrip1.PerformLayout();
            TabControlMain.ResumeLayout(false);
            ResumeLayout(false);
            PerformLayout();
        }

        #endregion

        private MenuStrip MenuStripMain;
        private ToolStripMenuItem MenuItemProgram;
        private ToolStripMenuItem MenuItemProgramOpenFile;
        private ToolStripMenuItem MenuItemProgramCloseFile;
        private ToolStripMenuItem MenuItemProgramNewFile;
        private ToolStripSeparator MenuItemProgramSep1;
        private ToolStripMenuItem MenuItemProgramExit;
        private ToolStripMenuItem MenuItemOptions;
        private ToolStripMenuItem MenuItemOptionsOptions;
        private ToolStripMenuItem MenuItemLanguage;
        private ToolStripMenuItem MenuItemLanguageEN;
        private ToolStripMenuItem MenuItemLanguageNL;
        private StatusStrip statusStrip1;
        private ToolStripStatusLabel ToolStripStatusLabel1;
        private ToolStripStatusLabel ToolStripStatusLabel2;
        private TabControl TabControlMain;
        private TabPage TabPageReadItems;
        private TabPage TabPageEditItems;
    }
}
