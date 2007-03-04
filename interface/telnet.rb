#!/usr/bin/ruby
require 'socket'

$is     = 0.chr
$send   = 1.chr
$status = 5.chr
$ttype  = 24.chr
$naws   = 31.chr
$se     = 240.chr
$sb     = 250.chr
$will   = 251.chr
$wont   = 252.chr
$do     = 253.chr
$dont   = 254.chr
$iac    = 255.chr

class Telnet
  def initialize()
    @socket = TCPSocket.open("nethack.alt.org", "telnet")
    @subnegotiation = ''
    @output = ''
    @mode = :text
    @type = nil
    @received_status = nil

    @ttyrec_name = "ttyrec/" + Time.now.strftime("%Y-%m-%d.%H:%M:%S") + ".ttyrec"
    @ttyrec_handle = File.new(@ttyrec_name, "w")

    @socket.send($iac + $do + $status, 0)
    send_and_recv_until('', /=> $/)
  end

  def print_to_ttyrec(output)
    return if output.length == 0
    t = Time.now
    header = [t.tv_sec, t.tv_usec, output.length].pack("VVV")
    @ttyrec_handle.print(header + output)
  end

  def close_ttyrec()
    @ttyrec_handle.flush()
    @ttyrec_handle.close()
  end

  def send_and_recv_until(s, regex)
    @socket.send(s, 0)
    @output = ''

    until @output =~ regex
      @output += recv_one()
    end

    print_to_ttyrec(@output)
    return @output
  end

  def send_and_recv(s)
    @socket.send(s, 0)
    @socket.send($iac + $sb + $status + $send + $iac + $se, 0)
    @output = ''

    @received_status = nil
    until @received_status == 1
      @output += recv_one()
    end
    @received_status = nil

    print_to_ttyrec(@output)

    return @output
  end

  def recv_one()
    c = @socket.recv(1)
    if c == ''
      print_to_ttyrec(@output)
      close_ttyrec()
      raise "Disconnected from server."
    end

    case @mode
      when :text
        if c == $iac
          @mode = :iac
        else
          return c
        end
      when :iac
        if c == $iac
          @mode = :text
          return $iac
        elsif c == $do || c == $dont || c == $will || c == $wont
          @mode = :dodontwillwont
          @type = c
        elsif c == $sb
          @mode = :sb
        end
      when :dodontwillwont
        if c == $status
          if @type == $do || @type == $dont
            @socket.send($iac + $wont + c, 0)
          end
        elsif c == $ttype
          if @type == $do || @type == $dont
            @socket.send($iac + $will + c, 0)
            @socket.send($iac + $sb + $ttype + $is + "VT220" + $iac + $se, 0)
          end
        elsif c == $naws
          if @type == $do || @type == $dont
            @socket.send($iac + $will + c, 0)
            @socket.send($iac + $sb + $naws + $is + 80.chr + $is + 24.chr + $iac + $se, 0)
          end
        else
          if @type == $do || @type == $dont
            @socket.send($iac + $wont + c, 0)
          elsif @type == $will || @type == $wont
            @socket.send($iac + $dont + c, 0)
          end
        end

        @mode = :text
      when :sb
        case c
        when $iac
          @mode = :sbiac
        else
          @subnegotiation += c
        end
      when :sbiac
        case c
        when $se
          @mode = :text
          if @subnegotiation[0].chr == $status
            @received_status = 1
          end
          @subnegotiation = ''
        else
          @subnegotiation += c
        end
    end
    return ''
  end
end

