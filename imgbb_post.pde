// https://www.baeldung.com/java-http-request

import java.io.*;
import java.net.HttpURLConnection;
import java.net.URLEncoder;
import java.net.URL;
import java.util.Base64;

import processing.video.*;

Capture video;


String imgbb_api_key = "7eb8c57ff080711867ed0dfb504b72e7";
String imgbb_url = "https://api.imgbb.com/1/upload";
boolean upload_pending = false;


void setup() {
  size(640, 480);

  video = new Capture(this, width, height);
  video.start();
}


void uploadImage() throws IOException {
  upload_pending = true;
  // Save image to disk first
  save("tmp.png");

  URL url = new URL(imgbb_url);
  HttpURLConnection con = (HttpURLConnection) url.openConnection();
  con.setDoOutput(true);
  con.setRequestMethod("POST");
  //con.setRequestProperty("Content-Type", "application/json");

  File imgFile = sketchFile("tmp.png");
  long fileSize = imgFile.length();
  byte[] allBytes = new byte[(int) fileSize];
  FileInputStream fis = new FileInputStream(imgFile);
  BufferedInputStream reader = new BufferedInputStream(fis);
  reader.read(allBytes);
  reader.close();

  String paramString = "key=" + imgbb_api_key + "&";
  paramString += "image=";
  paramString += URLEncoder.encode(Base64.getEncoder().encodeToString(allBytes), "UTF-8");

  DataOutputStream out = new DataOutputStream(con.getOutputStream());
  out.writeBytes(paramString);
  out.flush();
  out.close();

  int status = con.getResponseCode();
  BufferedReader in = new BufferedReader(new InputStreamReader(con.getInputStream()));
  String inputLine;
  StringBuilder content = new StringBuilder();
  while ((inputLine = in.readLine()) != null) {
    content.append(inputLine);
  }
  in.close();
  println(content.toString());

  if (status == 200) {
    println("Uploading done");
  } else {
    println("Error uploading file");
  }
  upload_pending = false;
}


void draw() {
  if (video.available() == true) {
    video.read();
  }
  
  image(video, 0, 0);
  
  fill(255);
  textSize(24);
  text("Cliquer pour uploader vers lpl-qiff.imgbb.com", 10, height - 20);
}


void mouseClicked() {
  if (!upload_pending) {
    println("envoi de l'image");
    thread("uploadImage");
  }
}
