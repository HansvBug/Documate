﻿//------------------------------------------------------------------------------
// <auto-generated>
//     This code was generated by a tool.
//     Runtime Version:4.0.30319.42000
//
//     Changes to this file may cause incorrect behavior and will be lost if
//     the code is regenerated.
// </auto-generated>
//------------------------------------------------------------------------------

namespace Documate.Resources.Models {
    using System;
    
    
    /// <summary>
    ///   A strongly-typed resource class, for looking up localized strings, etc.
    /// </summary>
    // This class was auto-generated by the StronglyTypedResourceBuilder
    // class via a tool like ResGen or Visual Studio.
    // To add or remove a member, edit your .ResX file then rerun ResGen
    // with the /str option, or rebuild your VS project.
    [global::System.CodeDom.Compiler.GeneratedCodeAttribute("System.Resources.Tools.StronglyTypedResourceBuilder", "17.0.0.0")]
    [global::System.Diagnostics.DebuggerNonUserCodeAttribute()]
    [global::System.Runtime.CompilerServices.CompilerGeneratedAttribute()]
    internal class AppDbMaintain {
        
        private static global::System.Resources.ResourceManager resourceMan;
        
        private static global::System.Globalization.CultureInfo resourceCulture;
        
        [global::System.Diagnostics.CodeAnalysis.SuppressMessageAttribute("Microsoft.Performance", "CA1811:AvoidUncalledPrivateCode")]
        internal AppDbMaintain() {
        }
        
        /// <summary>
        ///   Returns the cached ResourceManager instance used by this class.
        /// </summary>
        [global::System.ComponentModel.EditorBrowsableAttribute(global::System.ComponentModel.EditorBrowsableState.Advanced)]
        internal static global::System.Resources.ResourceManager ResourceManager {
            get {
                if (object.ReferenceEquals(resourceMan, null)) {
                    global::System.Resources.ResourceManager temp = new global::System.Resources.ResourceManager("Documate.Resources.Models.AppDbMaintain", typeof(AppDbMaintain).Assembly);
                    resourceMan = temp;
                }
                return resourceMan;
            }
        }
        
        /// <summary>
        ///   Overrides the current thread's CurrentUICulture property for all
        ///   resource lookups using this strongly typed resource class.
        /// </summary>
        [global::System.ComponentModel.EditorBrowsableAttribute(global::System.ComponentModel.EditorBrowsableState.Advanced)]
        internal static global::System.Globalization.CultureInfo Culture {
            get {
                return resourceCulture;
            }
            set {
                resourceCulture = value;
            }
        }
        
        /// <summary>
        ///   Looks up a localized string similar to The application database is compressed..
        /// </summary>
        internal static string CompressAppDb {
            get {
                return ResourceManager.GetString("CompressAppDb", resourceCulture);
            }
        }
        
        /// <summary>
        ///   Looks up a localized string similar to Compressing the application database failed..
        /// </summary>
        internal static string CompressAppDbFailed {
            get {
                return ResourceManager.GetString("CompressAppDbFailed", resourceCulture);
            }
        }
        
        /// <summary>
        ///   Looks up a localized string similar to Copy file.
        /// </summary>
        internal static string CopyFile {
            get {
                return ResourceManager.GetString("CopyFile", resourceCulture);
            }
        }
        
        /// <summary>
        ///   Looks up a localized string similar to The copying of the file &apos;{0}&apos; has been aborted..
        /// </summary>
        internal static string CopyFileAborted {
            get {
                return ResourceManager.GetString("CopyFileAborted", resourceCulture);
            }
        }
        
        /// <summary>
        ///   Looks up a localized string similar to Copying of the file {0} is complete..
        /// </summary>
        internal static string CopyFileReady {
            get {
                return ResourceManager.GetString("CopyFileReady", resourceCulture);
            }
        }
        
        /// <summary>
        ///   Looks up a localized string similar to The file already exists. Do you want to overwrite it?.
        /// </summary>
        internal static string FileExistOverwrite {
            get {
                return ResourceManager.GetString("FileExistOverwrite", resourceCulture);
            }
        }
        
        /// <summary>
        ///   Looks up a localized string similar to The file to copy does not exist..
        /// </summary>
        internal static string FileNotPresent {
            get {
                return ResourceManager.GetString("FileNotPresent", resourceCulture);
            }
        }
        
        /// <summary>
        ///   Looks up a localized string similar to The directory was not found..
        /// </summary>
        internal static string FolderNotPresent {
            get {
                return ResourceManager.GetString("FolderNotPresent", resourceCulture);
            }
        }
        
        /// <summary>
        ///   Looks up a localized string similar to Number of columns = {0}..
        /// </summary>
        internal static string NumberOfColsIs {
            get {
                return ResourceManager.GetString("NumberOfColsIs", resourceCulture);
            }
        }
        
        /// <summary>
        ///   Looks up a localized string similar to Request number of columns..
        /// </summary>
        internal static string RequestColCount {
            get {
                return ResourceManager.GetString("RequestColCount", resourceCulture);
            }
        }
        
        /// <summary>
        ///   Looks up a localized string similar to Failed to query column count. (Version: {0})..
        /// </summary>
        internal static string RequestColCountFailed {
            get {
                return ResourceManager.GetString("RequestColCountFailed", resourceCulture);
            }
        }
        
        /// <summary>
        ///   Looks up a localized string similar to Resetting the ranges in the application database is complete..
        /// </summary>
        internal static string ResetAppDbSequence {
            get {
                return ResourceManager.GetString("ResetAppDbSequence", resourceCulture);
            }
        }
        
        /// <summary>
        ///   Looks up a localized string similar to Resetting the sequences in the application database failed..
        /// </summary>
        internal static string ResetAppDbSequenceFailed {
            get {
                return ResourceManager.GetString("ResetAppDbSequenceFailed", resourceCulture);
            }
        }
    }
}