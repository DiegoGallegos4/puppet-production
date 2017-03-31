class nhproduction::ssl($certname, $certdir){
  exec{ 'create_sslcert':
    command => "openssl req -x509 -newkey rsa:2048 -days 365 -nodes -keyout ${certname}.key -out ${certname}.crt -subj '/C=HN/ST=Cortes/L=SPS/O=nuevoshorizontes/OU=it/CN=${certname}/emailAddress=developer@panoramalife.com'",
    cwd     => $certdir,
    creates => ["${certdir}/${certname}.key", "${certdir}/${certname}.csr"],
    path    => ["/usr/bin","/usr/sbin"]
  }
}
