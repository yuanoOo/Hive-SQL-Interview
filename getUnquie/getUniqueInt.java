package getUnquie;

import java.math.BigInteger;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.util.UUID;

public class getUniqueInt {
    private static char[] availableChars = {'a', 'b', 'c' ,'d','e','f','g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','v','w','x','y','z','A', 'B', 'C' ,'D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z','0','1','2','3','4','5','6','7','8','9'};

public static void main(String[] args) {
    String str = UUID.randomUUID().toString();
    System.out.println("UUID: " + str + " ==> " + str.length());
    System.out.println("Long_MAX_VALUE ===> " + Long.MAX_VALUE  + " ===> " + String.valueOf(Long.MAX_VALUE).length());
    System.out.println("A! ===> " + Math.pow(availableChars.length, 10));

    genLongFromStr1(str);
    genLongFromStr2(str);
    getUniqueInteger(str);
}


public static void genLongFromStr1(String string){
    long hash = 0;
    long base = 1;
    for (char c: string.toCharArray()){
        for (int key=0; key < availableChars.length; key++){
            if (availableChars[key] != c)
                continue;
            hash += base*key;
            base = base*availableChars.length;
        }
    }

    System.out.println(hash);
}


public static void genLongFromStr2(String inputString){
    int i=0;
    int total=1;
    String[] input = new String[35];
    char[] inputChar = inputString.toCharArray();
    for(char a = 'A' ; a<='Z' ; a++ ){
        i++;
        input[i-1] = a+":"+i;
    }
    for(char b = '1';b<='9';b++){
        i++;
        input[i-1] = String.valueOf(b)+":"+i;
    }
    
    for(int k=0;k<inputChar.length;k++){
      for(int j = 0;j<input.length;j++){
          if(input[j].charAt(0)==inputChar[k]){
    
              total*=Integer.parseInt(input[j].substring(input[j].indexOf(':')+1,input[j].length()));
          }
      }
    }  
    System.out.println(total);
}


public static void getUniqueInteger(String name){
    String plaintext = name;
    long hash = name.hashCode();
    MessageDigest m;
    try {
        m = MessageDigest.getInstance("MD5");
        m.reset();
        m.update(plaintext.getBytes());
        byte[] digest = m.digest();
        BigInteger bigInt = new BigInteger(1,digest);
        String hashtext = bigInt.toString(10);
        // Now we need to zero pad it if you actually want the full 32 chars.
        while(hashtext.length() < 32 ){
          hashtext = "0"+hashtext;
        }
        int temp = 0;
        for(int i =0; i<hashtext.length();i++){
            char c = hashtext.charAt(i);
            temp+=(int)c;
        }
        hash = hash+temp;
    } catch (NoSuchAlgorithmException e) {
        // TODO Auto-generated catch block
        e.printStackTrace();
    }
    System.out.println(hash);
}
}
