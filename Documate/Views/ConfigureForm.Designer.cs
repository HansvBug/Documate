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
            System.ComponentModel.ComponentResourceManager resources = new System.ComponentModel.ComponentResourceManager(typeof(ConfigureForm));
            tabControl1 = new TabControl();
            TabPageVarious = new TabPage();
            GroupBoxLogging = new GroupBox();
            ChkActivateLogging = new CheckBox();
            ChkAppendLogFile = new CheckBox();
            TabPageDatabase = new TabPage();
            BtnCompressDb = new Button();
            BtnClose = new Button();
            button1 = new Button();
            tabControl1.SuspendLayout();
            TabPageVarious.SuspendLayout();
            GroupBoxLogging.SuspendLayout();
            TabPageDatabase.SuspendLayout();
            SuspendLayout();
            // 
            // tabControl1
            // 
            tabControl1.Controls.Add(TabPageVarious);
            tabControl1.Controls.Add(TabPageDatabase);
            resources.ApplyResources(tabControl1, "tabControl1");
            tabControl1.Name = "tabControl1";
            tabControl1.SelectedIndex = 0;
            // 
            // TabPageVarious
            // 
            TabPageVarious.Controls.Add(GroupBoxLogging);
            resources.ApplyResources(TabPageVarious, "TabPageVarious");
            TabPageVarious.Name = "TabPageVarious";
            TabPageVarious.UseVisualStyleBackColor = true;
            // 
            // GroupBoxLogging
            // 
            GroupBoxLogging.Controls.Add(ChkActivateLogging);
            GroupBoxLogging.Controls.Add(ChkAppendLogFile);
            resources.ApplyResources(GroupBoxLogging, "GroupBoxLogging");
            GroupBoxLogging.Name = "GroupBoxLogging";
            GroupBoxLogging.TabStop = false;
            // 
            // ChkActivateLogging
            // 
            resources.ApplyResources(ChkActivateLogging, "ChkActivateLogging");
            ChkActivateLogging.Name = "ChkActivateLogging";
            ChkActivateLogging.UseVisualStyleBackColor = true;
            // 
            // ChkAppendLogFile
            // 
            resources.ApplyResources(ChkAppendLogFile, "ChkAppendLogFile");
            ChkAppendLogFile.Name = "ChkAppendLogFile";
            ChkAppendLogFile.UseVisualStyleBackColor = true;
            // 
            // TabPageDatabase
            // 
            TabPageDatabase.Controls.Add(BtnCompressDb);
            resources.ApplyResources(TabPageDatabase, "TabPageDatabase");
            TabPageDatabase.Name = "TabPageDatabase";
            TabPageDatabase.UseVisualStyleBackColor = true;
            // 
            // BtnCompressDb
            // 
            resources.ApplyResources(BtnCompressDb, "BtnCompressDb");
            BtnCompressDb.Name = "BtnCompressDb";
            BtnCompressDb.UseVisualStyleBackColor = true;
            // 
            // BtnClose
            // 
            resources.ApplyResources(BtnClose, "BtnClose");
            BtnClose.Name = "BtnClose";
            BtnClose.UseVisualStyleBackColor = true;
            // 
            // button1
            // 
            resources.ApplyResources(button1, "button1");
            button1.Name = "button1";
            button1.UseVisualStyleBackColor = true;
            button1.Click += button1_Click;
            // 
            // ConfigureForm
            // 
            resources.ApplyResources(this, "$this");
            AutoScaleMode = AutoScaleMode.Font;
            Controls.Add(button1);
            Controls.Add(BtnClose);
            Controls.Add(tabControl1);
            Name = "ConfigureForm";
            tabControl1.ResumeLayout(false);
            TabPageVarious.ResumeLayout(false);
            GroupBoxLogging.ResumeLayout(false);
            GroupBoxLogging.PerformLayout();
            TabPageDatabase.ResumeLayout(false);
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
        private Button button1;
        private Button BtnCompressDb;
    }
}