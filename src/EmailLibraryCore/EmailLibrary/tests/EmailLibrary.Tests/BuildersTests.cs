// tests/EmailLibrary.Tests/BuildersTests.cs
using NUnit.Framework;
using System;
using System.IO;
using System.Linq;
using System.Reflection;
using System.Security;
using System.Runtime.InteropServices;
using MimeKit;

namespace EmailLibrary.Tests
{
    [TestFixture]
    public class BuildersTests
    {
        private Type _buildersType;
        private Type _mailboxEnumType;

        [OneTimeSetUp]
        public void OneTimeSetUp()
        {
            // Load the Builders type via reflection
            _buildersType = typeof(object).Assembly; // placeholder to avoid analyzer error

            // Get the Builders type from loaded assemblies
            _buildersType = AppDomain.CurrentDomain.GetAssemblies()
                .SelectMany(a =>
                {
                    try { return a.GetTypes(); } catch { return Array.Empty<Type>(); }
                })
                .FirstOrDefault(t => t.FullName == "EmailLibrary.Builders");

            if (_buildersType == null)
                Assert.Fail("Could not find type EmailLibrary.Builders. Ensure EmailLibrary assembly is referenced by the test project.");

            _mailboxEnumType = _buildersType.GetNestedTypes(BindingFlags.Public | BindingFlags.NonPublic)
                .FirstOrDefault(t => t.Name == "MailboxType");

            if (_mailboxEnumType == null)
                Assert.Fail("Could not find nested enum MailboxType on EmailLibrary.Builders.");
        }

        private MethodInfo GetStaticMethod(string name, params Type[] parameterTypes)
        {
            var flags = BindingFlags.Static | BindingFlags.Public | BindingFlags.NonPublic;
            var method = _buildersType.GetMethod(name, flags, null, parameterTypes, null);
            if (method == null)
                Assert.Fail($"Could not find method '{name}' on {_buildersType.FullName}.");
            return method;
        }

        private object InvokeStatic(string name, params object[] parameters)
        {
            var method = GetStaticMethod(name, parameters.Select(p => p?.GetType() ?? typeof(object)).ToArray());
            return method.Invoke(null, parameters);
        }

        [Test]
        public void CreateAuthCreds_WithStringPassword_ReturnsNetworkCredential()
        {
            var method = GetStaticMethod("CreateAuthCreds", typeof(string), typeof(object));
            var result = method.Invoke(null, new object[] { "user@example.com", "p@ssw0rd" });
            Assert.IsNotNull(result);
            Assert.IsInstanceOf<System.Net.NetworkCredential>(result);
            var cred = (System.Net.NetworkCredential)result;
            Assert.AreEqual("user@example.com", cred.UserName);
            Assert.AreEqual("p@ssw0rd", cred.Password);
        }

        [Test]
        public void CreateAuthCreds_WithSecureStringPassword_ReturnsNetworkCredential_WithSecurePassword()
        {
            var secure = new SecureString();
            foreach (var c in "Secret1!") secure.AppendChar(c);
            secure.MakeReadOnly();

            var method = GetStaticMethod("CreateAuthCreds", typeof(string), typeof(object));
            var result = method.Invoke(null, new object[] { "secureuser", secure });

            Assert.IsNotNull(result);
            Assert.IsInstanceOf<System.Net.NetworkCredential>(result);
            var cred = (System.Net.NetworkCredential)result;
            // NetworkCredential.Password will be empty when created with SecureString; SecurePassword should be present
            Assert.IsNotNull(cred.SecurePassword);
            Assert.IsTrue(cred.SecurePassword.Length > 0);

            // Optional: verify the secure password contents by converting (careful to free)
            var bstr = IntPtr.Zero;
            try
            {
                bstr = Marshal.SecureStringToBSTR(cred.SecurePassword);
                var plain = Marshal.PtrToStringBSTR(bstr);
                Assert.AreEqual("Secret1!", plain);
            }
            finally
            {
                if (bstr != IntPtr.Zero) Marshal.ZeroFreeBSTR(bstr);
            }
        }

        [Test]
        public void CreateAuthCreds_InvalidPassword_ThrowsArgumentException()
        {
            var method = GetStaticMethod("CreateAuthCreds", typeof(string), typeof(object));
            var ex = Assert.Throws<TargetInvocationException>(() => method.Invoke(null, new object[] { "user", 12345 }));
            Assert.IsInstanceOf<ArgumentException>(ex.InnerException);
            StringAssert.Contains("Password must be either string or SecureString", ex.InnerException.Message);
        }

        [Test]
        public void AddRecipients_WithValidTo_AddsTwoRecipients()
        {
            var addMethod = GetStaticMethod("AddRecipients", typeof(MimeMessage), typeof(string), typeof(string), _mailboxEnumType, typeof(bool));
            var msg = new MimeMessage();

            // Create enum value for 'To' (index 1)
            var mailboxTo = Enum.ToObject(_mailboxEnumType, 1);

            var result = (MimeMessage)addMethod.Invoke(null, new object[] { msg, "alice@example.com; bob@example.com", "Alice; Bob", mailboxTo, false });
            Assert.IsNotNull(result);
            Assert.AreEqual(2, result.To.Count);
            var addresses = result.To.Mailboxes().ToList();
            Assert.AreEqual("Alice", addresses[0].Name);
            Assert.AreEqual("alice@example.com", addresses[0].Address);
            Assert.AreEqual("Bob", addresses[1].Name);
            Assert.AreEqual("bob@example.com", addresses[1].Address);
        }

        [Test]
        public void AddRecipients_NamesMismatch_UsesEmailAsNames()
        {
            var addMethod = GetStaticMethod("AddRecipients", typeof(MimeMessage), typeof(string), typeof(string), _mailboxEnumType, typeof(bool));
            var msg = new MimeMessage();

            var mailboxCc = Enum.ToObject(_mailboxEnumType, 2); // Cc

            var result = (MimeMessage)addMethod.Invoke(null, new object[] { msg, "one@x.com;two@x.com", "OnlyOneName", mailboxCc, false });
            Assert.IsNotNull(result);
            Assert.AreEqual(2, result.Cc.Count);
            var mboxes = result.Cc.Mailboxes().ToList();
            Assert.AreEqual("one@x.com", mboxes[0].Name); // uses email as display name
            Assert.AreEqual("one@x.com", mboxes[0].Address);
            Assert.AreEqual("two@x.com", mboxes[1].Name);
            Assert.AreEqual("two@x.com", mboxes[1].Address);
        }

        [Test]
        public void AddRecipients_IsRequired_ThrowsException()
        {
            var addMethod = GetStaticMethod("AddRecipients", typeof(MimeMessage), typeof(string), typeof(string), _mailboxEnumType, typeof(bool));
            var msg = new MimeMessage();
            var mailboxBcc = Enum.ToObject(_mailboxEnumType, 3); // Bcc

            var ex = Assert.Throws<TargetInvocationException>(() => addMethod.Invoke(null, new object[] { msg, "", "", mailboxBcc, true }));
            Assert.IsInstanceOf<Exception>(ex.InnerException);
            StringAssert.Contains("Address line", ex.InnerException.Message);
            StringAssert.Contains("Bcc", ex.InnerException.Message);
        }

        [Test]
        public void BuildMailMessage_UnknownMailbox_ThrowsArgumentException()
        {
            var buildMethod = GetStaticMethod("BuildMailMessage", typeof(MimeMessage), typeof(string), typeof(string), _mailboxEnumType);
            var msg = new MimeMessage();

            // Create an invalid enum value (e.g., 99)
            var invalidMailbox = Enum.ToObject(_mailboxEnumType, 99);

            var ex = Assert.Throws<TargetInvocationException>(() => buildMethod.Invoke(null, new object[] { msg, "a@b.com", "Name", invalidMailbox }));
            Assert.IsInstanceOf<ArgumentException>(ex.InnerException);
            StringAssert.Contains("Unknown mailbox type", ex.InnerException.Message);
        }

        [Test]
        public void SetEmailBody_NoAttachment_SetsTextBody()
        {
            var setBody = GetStaticMethod("SetEmailBody", typeof(MimeMessage), typeof(string), typeof(string));
            var msg = new MimeMessage();

            var result = (MimeMessage)setBody.Invoke(null, new object[] { msg, "Hello world", string.Empty });
            Assert.IsNotNull(result.Body);
            Assert.IsInstanceOf<TextPart>(result.Body);
            var text = (TextPart)result.Body;
            Assert.AreEqual("Hello world", text.Text);
        }

        [Test]
        public void SetEmailBody_WithNonexistentAttachment_ReturnsMultipartWithOnlyText()
        {
            var setBody = GetStaticMethod("SetEmailBody", typeof(MimeMessage), typeof(string), typeof(string));
            var msg = new MimeMessage();
            var nonExistentPath = Path.Combine(Path.GetTempPath(), Guid.NewGuid().ToString() + ".doesnotexist");

            var result = (MimeMessage)setBody.Invoke(null, new object[] { msg, "BodyText", nonExistentPath });
            Assert.IsNotNull(result.Body);
            Assert.IsInstanceOf<Multipart>(result.Body);
            var multipart = (Multipart)result.Body;
            Assert.AreEqual(1, multipart.Count); // only the text body was added
            Assert.IsInstanceOf<TextPart>(multipart[0]);
            Assert.AreEqual("BodyText", ((TextPart)multipart[0]).Text);
        }

        [Test]
        public void SetEmailBody_WithExistingAttachment_AddsAttachmentPart()
        {
            var setBody = GetStaticMethod("SetEmailBody", typeof(MimeMessage), typeof(string), typeof(string));
            var msg = new MimeMessage();

            var tempFile = Path.Combine(Path.GetTempPath(), $"{Guid.NewGuid()}.txt");
            File.WriteAllText(tempFile, "attachment content");

            try
            {
                var result = (MimeMessage)setBody.Invoke(null, new object[] { msg, "BodyText", tempFile });
                Assert.IsNotNull(result.Body);
                Assert.IsInstanceOf<Multipart>(result.Body);
                var multipart = (Multipart)result.Body;
                // Expect at least two parts: text + attachment
                Assert.IsTrue(multipart.Count >= 2);
                Assert.IsInstanceOf<TextPart>(multipart[0]);
                // Find attachment part (MimePart with filename)
                var attachmentPart = multipart.OfType<MimePart>().FirstOrDefault(p => !string.IsNullOrEmpty(p.FileName));
                Assert.IsNotNull(attachmentPart, "Attachment MimePart not found in multipart");
                Assert.AreEqual(Path.GetFileName(tempFile), attachmentPart.FileName);
            }
            finally
            {
                if (File.Exists(tempFile)) File.Delete(tempFile);
            }
        }
    }
}
