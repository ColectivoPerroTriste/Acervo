#!/usr/bin/env ruby
# encoding: UTF-8
# coding: UTF-8

# REQUIERE DE WGET, IMAGEMAGICK Y DE ESTA GEMA: gem install rmagick
require 'rmagick'

Encoding.default_internal = Encoding::UTF_8

# GENERALES

# Obtiene el tipo de sistema operativo; viene de: http://stackoverflow.com/questions/170956/how-can-i-find-which-operating-system-my-ruby-program-is-running-on
module OS
    def OS.windows?
        (/cygwin|mswin|mingw|bccwin|wince|emx/ =~ RUBY_PLATFORM) != nil
    end
    def OS.mac?
        (/darwin/ =~ RUBY_PLATFORM) != nil
    end
    def OS.unix?
        !OS.windows?
    end
    def OS.linux?
        OS.unix? and not OS.mac?
    end
end

# Enmienda ciertos problemas con la línea de texto
def arregloRuta (elemento)
    if elemento[-1] == ' '
        elemento = elemento[0...-1]
    end

    # Elimina caracteres conficlitos
    elementoFinal = elemento.gsub('\ ', ' ').gsub('\'', '')

    if OS.windows?
        # En Windows cuando hay rutas con espacios se agregan comillas dobles que se tiene que eliminar
        elementoFinal = elementoFinal.gsub('"', '')
    else
        # En UNIX pueden quedar diagonales de espace que también se ha de eliminar
        elementoFinal =  elementoFinal.gsub('\\', '')
    end

    # Se codifica para que no exista problemas con las tildes
    elementoFinal = elementoFinal.encode!(Encoding::UTF_8)

    return elementoFinal
end

# SCRIPT

$urlTXT = arregloRuta ARGF.argv[0]	# El único argumento del script tiene que ser url.txt
$enlaces = Array.new	# Aquí se guardarán los enlaces de las imágenes
$ruta = (File.absolute_path $urlTXT).split("/")[0...-1].join("/")	# La ruta absoluta del directorio
$json = "json"	# Para las carpetas para los archivos que se crearán
$thumbs = "thumbs"	# Para las carpetas para los archivos que se crearán
$tamano = 512	# El tamaño máximo de la altura o anchura para la imagen de thumbnail, manteniendo su relación de aspecto

# Va a la carpeta si no está ahí
Dir.chdir $ruta

# Abre el archivo y extrae los enlaces
archivoTXT = File.open($urlTXT, 'r:UTF-8')
archivoTXT.each do |linea|
    linea = linea.strip
    if linea != ""
        $enlaces.push(linea)
    end
end

$enlaces.each do |item|
#	if item == $enlaces.first	# COMENTAR UNA VEZ TERMINADA LA PRUEBA
	
		puts "\nCreando nuevo ítem..."
		
		# Obtiene la url para descargar el anverso y el reverso
		$a_url_wget = item.split(",").first
		$r_url_wget = item.split(",").last
		
		# Crea las carpetas si no existen
		if !(File.directory? $json)
			Dir.mkdir $json
		end
		if !(File.directory? $thumbs)
			Dir.mkdir $thumbs
		end
		
		# Para el JSON
		$num_inventario = $a_url_wget.split("/").last.split(".").first[1...-1].to_i
		$autoria = "Gabriel Portillo del Toro"
		$titulo = "T"
		$lenguaje = "es"
		$etiquetas = "T, T"
		$f_fecha = "UTC"
		$f_lugar = "Colima"
		$f_tecnica = "T sobre papel"
		$f_soporte = "Papel"
		$f_anchura_cm = 0
		$f_altura_cm = 0
		$f_estado = "Bueno"
		$f_localizacion = "Familia Portillo del Toro"
		$f_notas = ""
		$d_fecha = "2016-05-08T12:00:00Z"				# Buscar si se puede sacar la fecha de creación
		$d_lugar = "Colima"
		$d_tecnica = "Escáner plano"
		$d_a_nombre = $a_url_wget.split("/").last.split("?").first
		$d_a_tamano_mb
		$d_a_anchura_px
		$d_a_altura_px
		$d_a_url = $a_url_wget
		$d_a_url_thumb = "#{$thumbs}/" + $d_a_nombre.split(".").first + ".jpg"
		$d_a_notas = ""
		$d_r_nombre = $r_url_wget.split("/").last.split("?").first
		$d_r_tamano_mb
		$d_r_anchura_px
		$d_r_altura_px
		$d_r_url = $r_url_wget
		$d_r_url_thumb = "/#{$thumbs}/" + $d_r_nombre.split(".").first + ".jpg"
		$d_r_notas = ""
		
		# Solo faltan estas variables:
		# $d_a_tamano_mb
		# $d_a_anchura_px
		# $d_a_altura_px
		# $d_r_tamano_mb
		# $d_r_anchura_px
		# $d_r_altura_px
		# Se obtendrán al descargar el archivo
		
		# Descarga la imagen, obtiene los datos necesarios y crea el thumb
		def imgData url
			# Obtiene el nombre según si es anverso o reverso
			if url == $a_url_wget
				nombre = $d_a_nombre
			else
				nombre = $d_r_nombre
			end
			
			# Obtiene la ruta absoluta de la imagen descargada o por descargar
			ruta = $ruta + "/#{$thumbs}/#{nombre}"
		
			# Descarga la imagen en la carpeta y nombre requeridos si no se ha llevado a cabo
			if !(File.exists? ruta)
				puts "\nDescargando #{nombre} en #{$ruta}/#{$thumbs}..."
				`wget -q --show-progress -O #{$thumbs}/#{nombre} #{url}`
			else
				puts "\n#{nombre} ya existe."
			end
			
			puts "\nObteniendo información de la imagen..."
			
			# Verifica si la imagen ha sido descargada correctamente, de lo contrario, reinicia este proceso
			begin
				$img = Magick::Image::read(ruta).first
			rescue
				puts "\n¡Hay un error en la imagen! Volviendo a descargar..."
				File.delete(ruta)
				imgData url
			end

			# Se obtiene el tamaño en pixeles y el peso en megabytes
			anchura = $img.columns.to_s
			altura = $img.rows.to_s
			tamano = ($img.filesize.to_f / 2**20).round(2)	# Sin rmagick sería: (File.size(ruta).to_f / 2**20).round(2)
			
			# Según si es anverso o reverso, guarda las variables
			if nombre == $d_a_nombre
				$d_a_tamano_mb = tamano
				$d_a_anchura_px = anchura
				$d_a_altura_px = altura
			else
				$d_r_tamano_mb = tamano
				$d_r_anchura_px = anchura
				$d_r_altura_px = altura
			end
			
			puts "\nCreando thumbnail..."
			
			# Cambia de tamaño a la imagen
			img_nueva = $img.resize_to_fit($tamano)
			img_nueva.write("#{$thumbs}/#{nombre.split(".").first}.jpg"){self.quality=100}
			
			puts "\nEliminando imagen original..."
			
			# Elimina la imagen original
			File.delete(ruta)
		end
		
		imgData $a_url_wget
		imgData $r_url_wget
		
		puts "\nCreando archivo JSON..."
		
		nombre = $d_a_nombre.split("-").first
		
		# Crea el archivo JSON según los parámetros estipulados
		json = File.new("#{$json}/#{nombre}.json", "w")
		json.puts "{"
		json.puts "    \"num_inventario\": #{$num_inventario},"
		json.puts "    \"autoria\": \"#{$autoria}\","
		json.puts "    \"titulo\": \"#{$titulo}\","
		json.puts "    \"lenguaje\": \"#{$lenguaje}\","
		json.puts "    \"etiquetas\": \"#{$etiquetas}\","
		json.puts "    \"fisico\": {"
		json.puts "        \"fecha\": \"#{$f_fecha}\","
		json.puts "        \"lugar\": \"#{$f_lugar}\","
		json.puts "        \"tecnica\": \"#{$f_tecnica}\","
		json.puts "        \"soporte\": \"#{$f_soporte}\","
		json.puts "        \"anchura_cm\": #{$f_anchura_cm},"
		json.puts "        \"altura_cm\": #{$f_altura_cm},"
		json.puts "        \"estado\": \"#{$f_estado}\","
		json.puts "        \"localizacion\": \"#{$f_localizacion}\","
		json.puts "        \"notas\": \"#{$f_notas}\""
		json.puts "    },"
		json.puts "    \"digital\": {"
		json.puts "        \"fecha\": \"#{$d_fecha}\","
		json.puts "        \"lugar\": \"#{$d_lugar}\","
		json.puts "        \"tecnica\": \"#{$d_tecnica}\","
		json.puts "        \"anverso\": {"
		json.puts "            \"nombre\": \"#{$d_a_nombre}\","
		json.puts "            \"tamano_mb\": #{$d_a_tamano_mb},"
		json.puts "            \"anchura_px\": #{$d_a_anchura_px},"
		json.puts "            \"altura_px\": #{$d_a_altura_px},"
		json.puts "            \"url\": \"#{$d_a_url}\","
		json.puts "            \"url_thumb\": \"#{$d_a_url_thumb}\","
		json.puts "            \"notas\": \"#{$d_a_notas}\""
		json.puts "        },"
		json.puts "        \"reverso\": {"
		json.puts "            \"nombre\": \"#{$d_r_nombre}\","
		json.puts "            \"tamano_mb\": #{$d_r_tamano_mb},"
		json.puts "            \"anchura_px\": #{$d_r_anchura_px},"
		json.puts "            \"altura_px\": #{$d_r_altura_px},"
		json.puts "            \"url\": \"#{$d_r_url}\","
		json.puts "            \"url_thumb\": \"#{$d_r_url_thumb}\","
		json.puts "            \"notas\": \"#{$d_r_notas}\""
		json.puts "        }"
		json.puts "    }"
		json.puts "}"
		json.close
		
		puts "\n¡El nuevo ítem para #{nombre} ha sido creado!"
		
#	end							# COMENTAR UNA VEZ TERMINADA LA PRUEBA
end
