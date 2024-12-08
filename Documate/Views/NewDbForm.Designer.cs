namespace Documate.Views
{
    partial class NewDbForm
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
            System.ComponentModel.ComponentResourceManager resources = new System.ComponentModel.ComponentResourceManager(typeof(NewDbForm));
            TextBoxFileName = new TextBox();
            TextBoxColCount = new TextBox();
            TextBoxShortDescription = new TextBox();
            LbFileName = new Label();
            LbColCount = new Label();
            LbShortDescription = new Label();
            BtSave = new Button();
            BtCancel = new Button();
            LbWarning = new Label();
            SuspendLayout();
            // 
            // TextBoxFileName
            // 
            resources.ApplyResources(TextBoxFileName, "TextBoxFileName");
            TextBoxFileName.Name = "TextBoxFileName";
            // 
            // TextBoxColCount
            // 
            resources.ApplyResources(TextBoxColCount, "TextBoxColCount");
            TextBoxColCount.Name = "TextBoxColCount";
            // 
            // TextBoxShortDescription
            // 
            resources.ApplyResources(TextBoxShortDescription, "TextBoxShortDescription");
            TextBoxShortDescription.Name = "TextBoxShortDescription";
            // 
            // LbFileName
            // 
            resources.ApplyResources(LbFileName, "LbFileName");
            LbFileName.Name = "LbFileName";
            // 
            // LbColCount
            // 
            resources.ApplyResources(LbColCount, "LbColCount");
            LbColCount.Name = "LbColCount";
            // 
            // LbShortDescription
            // 
            resources.ApplyResources(LbShortDescription, "LbShortDescription");
            LbShortDescription.Name = "LbShortDescription";
            // 
            // BtSave
            // 
            resources.ApplyResources(BtSave, "BtSave");
            BtSave.Name = "BtSave";
            BtSave.UseVisualStyleBackColor = true;
            // 
            // BtCancel
            // 
            resources.ApplyResources(BtCancel, "BtCancel");
            BtCancel.Name = "BtCancel";
            BtCancel.UseVisualStyleBackColor = true;
            // 
            // LbWarning
            // 
            resources.ApplyResources(LbWarning, "LbWarning");
            LbWarning.ForeColor = Color.Red;
            LbWarning.Name = "LbWarning";
            // 
            // NewDbForm
            // 
            resources.ApplyResources(this, "$this");
            AutoScaleMode = AutoScaleMode.Font;
            Controls.Add(LbWarning);
            Controls.Add(BtCancel);
            Controls.Add(BtSave);
            Controls.Add(LbShortDescription);
            Controls.Add(LbColCount);
            Controls.Add(LbFileName);
            Controls.Add(TextBoxShortDescription);
            Controls.Add(TextBoxColCount);
            Controls.Add(TextBoxFileName);
            Name = "NewDbForm";
            ResumeLayout(false);
            PerformLayout();
        }

        #endregion

        private TextBox TextBoxFileName;
        private TextBox TextBoxColCount;
        private TextBox TextBoxShortDescription;
        private Label LbFileName;
        private Label LbColCount;
        private Label LbShortDescription;
        private Button BtSave;
        private Button BtCancel;
        private Label LbWarning;
    }
}