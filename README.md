# Megapixels qrcode postprocess script
The purpose of this script is to provide a simple way to view qr codes from megapixels. Intended for use with a pinephone or librem 5.

# How to use it
1. Install the postprocess script (see below)
2. Open up megapixels and point your phone at a qr code.
3. If a QR code is detected a blue box will appear around the qr code (this is via megapixel's own processing not this script)
4. Take a picture of the qr code with that blue box around it. (bottom middle circular button)
5. Wait for the picture to be processed(You'll see a spinning thing in the bottom left). This may take a few seconds
6. A dialog box should pop up saying a qr code was found in the provided image. Depending on the qr code, it will ask if you want to see the contents or perform an action based on the contents. 

NOTE: if you say yes to performing an action related to the qr code, it will delete the image, as presumably it's not needed anymore. If you guys disagree with this functionality let me know.

# Installation Instructions
1. First you will need to install the following via apt-get:
```
sudo apt-get install megapixels zenity zbar-tools
```
2. Then you need to make a directory for the postprocess script to live
```
mkdir -p ~purism/.config/megapixels
```
3. Download the postprocess script from https://raw.githubusercontent.com/steve5289/megapixels-qrcode-postprocess/master/postprocess.sh, and place it in the ~purism/.config/megapixels/ keeping the name postprocess.sh
```
cd ~purism/.config/megapixels/
wget https://raw.githubusercontent.com/steve5289/megapixels-qrcode-postprocess/master/postprocess.sh
```
4. Set the permissions on the script to 755 (basically make it executable)
```
chmod 755 postprocess.sh
```


THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
