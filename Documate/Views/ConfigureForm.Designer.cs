namespace Documate
{
    partial class ConfigureForm
    {
        /// <summary>
        /// Required designer variable.
        /// </summary>
        private System.ComponentModel.IContainer components = null;

        /// <summary>
        /// Clean up any resources being used.
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
        /// Required method for Designer support - do not modify
        /// the contents of this method with the code editor.
        /// </summary>
        private void InitializeComponent()
        {
            tabControl1 = new TabControl();
            TabPageVarious = new TabPage();
            groupBox1 = new GroupBox();
            ChkActivateLogging = new CheckBox();
            ChkAppendLogFile = new CheckBox();
            TabPageDatabase = new TabPage();
            BtnClose = new Button();
            button1 = new Button();
            tabControl1.SuspendLayout();
            TabPageVarious.SuspendLayout();
            groupBox1.SuspendLayout();
            SuspendLayout();
            // 
            // tabControl1
            // 
            tabControl1.Controls.Add(TabPageVarious);
            tabControl1.Controls.Add(TabPageDatabase);
            tabControl1.Location = new Point(90, 34);
            tabControl1.Name = "tabControl1";
            tabControl1.SelectedIndex = 0;
            tabControl1.Size = new Size(602, 344);
            tabControl1.TabIndex = 0;
            // 
            // TabPageVarious
            // 
            TabPageVarious.Controls.Add(groupBox1);
            TabPageVarious.Location = new Point(4, 34);
            TabPageVarious.Name = "TabPageVarious";
            TabPageVarious.Padding = new Padding(3);
            TabPageVarious.Size = new Size(594, 306);
            TabPageVarious.TabIndex = 0;
            TabPageVarious.Text = "TabPageVarious";
            TabPageVarious.UseVisualStyleBackColor = true;
            // 
            // groupBox1
            // 
            groupBox1.Controls.Add(ChkActivateLogging);
            groupBox1.Controls.Add(ChkAppendLogFile);
            groupBox1.Location = new Point(6, 6);
            groupBox1.Name = "groupBox1";
            groupBox1.Size = new Size(348, 185);
            groupBox1.TabIndex = 2;
            groupBox1.TabStop = false;
            groupBox1.Text = "groupBox1";
            // 
            // ChkActivateLogging
            // 
            ChkActivateLogging.AutoSize = true;
            ChkActivateLogging.Location = new Point(6, 30);
            ChkActivateLogging.Name = "ChkActivateLogging";
            ChkActivateLogging.Size = new Size(197, 29);
            ChkActivateLogging.TabIndex = 0;
            ChkActivateLogging.Text = "ChkActivateLogging";
            ChkActivateLogging.UseVisualStyleBackColor = true;
            // 
            // ChkAppendLogFile
            // 
            ChkAppendLogFile.AutoSize = true;
            ChkAppendLogFile.Location = new Point(6, 65);
            ChkAppendLogFile.Name = "ChkAppendLogFile";
            ChkAppendLogFile.Size = new Size(188, 29);
            ChkAppendLogFile.TabIndex = 1;
            ChkAppendLogFile.Text = "ChkAppendLogFile";
            ChkAppendLogFile.UseVisualStyleBackColor = true;
            // 
            // TabPageDatabase
            // 
            TabPageDatabase.Location = new Point(4, 34);
            TabPageDatabase.Name = "TabPageDatabase";
            TabPageDatabase.Padding = new Padding(3);
            TabPageDatabase.Size = new Size(594, 306);
            TabPageDatabase.TabIndex = 1;
            TabPageDatabase.Text = "TabPageDatabase";
            TabPageDatabase.UseVisualStyleBackColor = true;
            // 
            // BtnClose
            // 
            BtnClose.Anchor = AnchorStyles.Bottom | AnchorStyles.Right;
            BtnClose.Location = new Point(676, 404);
            BtnClose.Name = "BtnClose";
            BtnClose.Size = new Size(112, 34);
            BtnClose.TabIndex = 1;
            BtnClose.Text = "BtnClose";
            BtnClose.UseVisualStyleBackColor = true;
            // 
            // button1
            // 
            button1.Location = new Point(437, 394);
            button1.Name = "button1";
            button1.Size = new Size(112, 34);
            button1.TabIndex = 2;
            button1.Text = "button1";
            button1.UseVisualStyleBackColor = true;
            // 
            // ConfigureForm
            // 
            AutoScaleDimensions = new SizeF(10F, 25F);
            AutoScaleMode = AutoScaleMode.Font;
            ClientSize = new Size(800, 450);
            Controls.Add(button1);
            Controls.Add(BtnClose);
            Controls.Add(tabControl1);
            Name = "ConfigureForm";
            Text = "ConfigureForm";
            tabControl1.ResumeLayout(false);
            TabPageVarious.ResumeLayout(false);
            groupBox1.ResumeLayout(false);
            groupBox1.PerformLayout();
            ResumeLayout(false);
        }

        #endregion

        private TabControl tabControl1;
        private TabPage TabPageVarious;
        private GroupBox groupBox1;
        private CheckBox ChkActivateLogging;
        private CheckBox ChkAppendLogFile;
        private TabPage TabPageDatabase;
        private Button BtnClose;
        private Button button1;
    }
}