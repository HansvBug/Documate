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
            GroupBoxLogging = new GroupBox();
            ChkActivateLogging = new CheckBox();
            ChkAppendLogFile = new CheckBox();
            TabPageDatabase = new TabPage();
            BtnClose = new Button();
            tabControl1.SuspendLayout();
            TabPageVarious.SuspendLayout();
            GroupBoxLogging.SuspendLayout();
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
            TabPageVarious.Controls.Add(GroupBoxLogging);
            TabPageVarious.Location = new Point(4, 34);
            TabPageVarious.Name = "TabPageVarious";
            TabPageVarious.Padding = new Padding(3);
            TabPageVarious.Size = new Size(594, 306);
            TabPageVarious.TabIndex = 0;
            TabPageVarious.Text = "TabPageVarious";
            TabPageVarious.UseVisualStyleBackColor = true;
            // 
            // GroupBoxLogging
            // 
            GroupBoxLogging.Controls.Add(ChkActivateLogging);
            GroupBoxLogging.Controls.Add(ChkAppendLogFile);
            GroupBoxLogging.Location = new Point(6, 6);
            GroupBoxLogging.Name = "GroupBoxLogging";
            GroupBoxLogging.Size = new Size(348, 185);
            GroupBoxLogging.TabIndex = 2;
            GroupBoxLogging.TabStop = false;
            GroupBoxLogging.Text = "groupBox1";
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
            // ConfigureForm
            // 
            AutoScaleDimensions = new SizeF(10F, 25F);
            AutoScaleMode = AutoScaleMode.Font;
            ClientSize = new Size(800, 450);
            Controls.Add(BtnClose);
            Controls.Add(tabControl1);
            Name = "ConfigureForm";
            Text = "ConfigureForm";
            tabControl1.ResumeLayout(false);
            TabPageVarious.ResumeLayout(false);
            GroupBoxLogging.ResumeLayout(false);
            GroupBoxLogging.PerformLayout();
            ResumeLayout(false);
        }

        #endregion

        private TabControl tabControl1;
        private TabPage TabPageVarious;
        private GroupBox GroupBoxLogging;
        private CheckBox ChkActivateLogging;
        private CheckBox ChkAppendLogFile;
        private TabPage TabPageDatabase;
        private Button BtnClose;
    }
}