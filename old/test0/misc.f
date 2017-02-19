C c
C c     version 1.3  Aug 1992
C c
C c     Misc routines for RAYINVR
C c
C c     ----------------------------------------------------------------
C c
C       subroutine ttime(is,xshot,npt,nr,a1,ifam,itt,iszero,iflag,
C      +                 uf,irayf)
C c
C c     calculate travel time along a single ray using the equation:
C c
C c                       t=2*h/(v1+v2)
C c
C c     for the travel time between two points a distance h apart
C c
C       include 'rayinvr.par'
C       real vave(ppray)
C       integer itt(1)
C       include 'rayinvr.com'
C c
C       if(idump.eq.1) write(12,15) ifam,nr,npt,xr(npt),zr(npt),
C      +  ar(npt,1)*pi18,ar(npt,2)*pi18,vr(npt,1),vr(npt,2),
C      +  layer,iblk,id,iwave
C 15    format(i2,i3,i4,2f8.3,2f8.2,2f7.2,4i3)
C c
C       time=0.
C       iflagw=0
C c
C       do 10 i=1,npt-1
C          tr(i)=sqrt((xr(i+1)-xr(i))**2+(zr(i+1)-zr(i))**2)
C          vave(i)=(vr(i,2)+vr(i+1,1))/2.
C          if(iflagw.eq.0.and.vave(i).gt.1.53) iflagw=1
C          if(iflagw.eq.1.and.vave(i).lt.1.53.and.nr.ne.0) then
C c          write(67,25) nr,xr(i),zr(i),time,uf,irayf
C 25         format(i5,4f10.3,i10)
C            iflagw=2
C          end if
C          time=time+tr(i)/vave(i)
C 10    continue
C c
C       a2=fid1*(90.-fid*ar(npt,1)*pi18)/fid
C       nptr=npt
C       if(vred.eq.0.) then
C         timer=time
C       else
C         timer=time-abs(xr(npt)-xshot)/vred
C       end if
C       rayid(ntt)=float(idray(1))+float(idray(2))/10.
C       if(nr.eq.0) go to 999
C       write(11,5) is,nr,a1,a2,xr(npt),zr(npt),timer,nptr,
C      +            rayid(ntt)
C 5     format(2i4,2f9.3,f9.3,f8.2,f8.3,i6,f6.1)
C       if(vr(npt,2).ne.0.) then
C         itt(ifam)=itt(ifam)+1
C         if(iszero.eq.0) then
C           range(ntt)=xr(npt)
C         else
C           range(ntt)=abs(xr(npt)-xshot)
C         end if
C         tt(ntt)=timer
C         xshtar(ntt)=xshot
C         fidarr(ntt)=fid1
C         ntt=ntt+1
C       end if
C 999   return
C       end
C c
C c     ----------------------------------------------------------------
C c
      subroutine sort(x,npts)
c
c     sort the elements of array x in order of increasing size using
c     a bubble sort technique
c
      real x(1)
      do 10 i=1,npts-1
         iflag=0
         do 20 j=1,npts-1
            if(x(j).gt.x(j+1)) then
              iflag=1
              xh=x(j)
              x(j)=x(j+1)
              x(j+1)=xh
            end if
20       continue
         if(iflag.eq.0) return
10     continue
      return
      end
C c
C c     ----------------------------------------------------------------
C c
C       subroutine smooth(x,n)
C c
C c     three point triangular smoothing filter
C c
C       real x(n)
C       m=n-1
C       a=0.77*x(1)+0.23*x(2)
C       b=0.77*x(n)+0.23*x(m)
C       xx=x(1)
C       xr=x(2)
C       do 10 i=2,m
C          xl=xx
C          xx=xr
C          xr=x(i+1)
C          x(i)=0.54*xx+0.23*(xl+xr)
C  10   continue
C       x(1)=a
C       x(n)=b
C       return
C       end
C c
C c     ----------------------------------------------------------------
C c
C       subroutine smooth2(x,n,n1,n2)
C c
C c     three point triangular smoothing filter
C c
C       real x(n)
C       m=n-1
C       a=0.77*x(1)+0.23*x(2)
C       b=0.77*x(n)+0.23*x(m)
C       xx=x(1)
C       xr=x(2)
C       do 10 i=2,m
C          xl=xx
C          xx=xr
C          xr=x(i+1)
C          if(i.lt.n1.or.i.gt.n2) x(i)=0.54*xx+0.23*(xl+xr)
C  10   continue
C       if(n1.gt.1) x(1)=a
C       if(n2.lt.n) x(n)=b
C       return
C       end
C c
C c     ----------------------------------------------------------------
C c
C       subroutine sort3(ra,rb,n)
C c
C c     sort the elements of array x in order of increasing size using
C c     a heapsort technique
C c
C       real ra(n)
C       integer rb(n)
C c
C       do 30 i=1,n
C          rb(i)=i
C 30    continue
C c
C       l=n/2+1
C       ir=n
C c
C 10    continue
C c
C       if(l.gt.1) then
C         l=l-1
C         rra=ra(l)
C         rrb=rb(l)
C       else
C         rra=ra(ir)
C         rrb=rb(ir)
C         ra(ir)=ra(1)
C         rb(ir)=rb(1)
C         ir=ir-1
C         if(ir.eq.1) then
C           ra(1)=rra
C           rb(1)=rrb
C           return
C         end if
C       end if
C       i=l
C       j=l+l
C 20    if(j.le.ir) then
C         if(j.lt.ir) then
C           if(ra(j).lt.ra(j+1)) j=j+1
C         end if
C         if(rra.lt.ra(j)) then
C           ra(i)=ra(j)
C           rb(i)=rb(j)
C           i=j
C           j=j+j
C         else
C           j=ir+1
C         end if
C         go to 20
C       end if
C       ra(i)=rra
C       rb(i)=rrb
C       go to 10
C c
C       end
C c
C c     ----------------------------------------------------------------
C c
C       subroutine modwr(modout,dx,dz,modi,ifrbnd,frz,xmmin,xmmax)
C c
C c     output the velocity model on a uniform grid for input to the
C c     plotting program MODPLT
C c
C       include 'rayinvr.par'
C       include 'rayinvr.com'
C c
C       real vzgrid(pxgrid),xgrid(player+1),xgmt(pxgrid),zgmt(pxgrid)
C       integer igrid(player+1),modi(player),zsmax(pxgrid)
C c
C       write(31,5) xmmin,xmmax,zmin,zmax,zmin,dx,dz
C 5     format(7f10.3)
C c
C       nx=nint((xmmax-xmmin)/dx)
C       nz=nint((zmax-zmin)/dz)
C c
C       write(31,15) nx,nz
C 15    format(10i7)
C c
C       if(abs(modout).eq.3) then
C         do 310 j=1,nx
C            do i=nz,1,-1
C               if(sample(i,j).gt.0) then
C                 zsmax(j)=i
C                 go to 310
C               end if
C            enddo
C            zsmax(j)=0
C 310     continue
C       end if
C c
C       do 10 i=1,nz+1
C          zmod=zmin+float(i-1)*dz
C          do 20 j=1,nx+1
C             xmod=xmmin+float(j-1)*dx
C c
C             call xzpt(xmod,zmod,layer,iblk,iflag)
C c
C             if(iflag.eq.0) then
C               vzgrid(j)=vel(xmod,zmod)
C             else
C               vzgrid(j)=9.999
C             end if
C c
C             xgmt(j)=xmod
C             zgmt(j)=zmod
C             if(modout.le.-2) zgmt(j)=-zgmt(j)
C c
C 20       continue
C c
C          if(abs(modout).eq.2) then
C            do 110 j=1,nx+1
C               iflag=0
C               if(i.gt.1.and.j.gt.1) then
C                 if(sample(i-1,j-1).gt.0) iflag=1
C               end if
C               if(i.gt.1.and.j.le.nx) then
C                 if(sample(i-1,j).gt.0) iflag=1
C               end if
C               if(j.gt.1.and.i.le.nz) then
C                 if(sample(i,j-1).gt.0) iflag=1
C               end if
C               if(i.le.nz.and.j.le.nx) then
C                 if(sample(i,j).gt.0) iflag=1
C               end if
C               if(iflag.eq.0) vzgrid(j)=9.999
C               if(iflag.eq.1) then
C                 jl=j
C                 go to 111
C               end if
C 110        continue
C 111        if (jl.lt.nx+1) then
C              do 120 j=nx+1,jl,-1
C                 iflag=0
C                 if(i.gt.1.and.j.gt.1) then
C                   if(sample(i-1,j-1).gt.0) iflag=1
C                 end if
C                 if(i.gt.1.and.j.le.nx) then
C                   if(sample(i-1,j).gt.0) iflag=1
C                 end if
C                 if(j.gt.1.and.i.le.nz) then
C                   if(sample(i,j-1).gt.0) iflag=1
C                 end if
C                 if(i.le.nz.and.j.le.nx) then
C                   if(sample(i,j).gt.0) iflag=1
C                 end if
C                 if(iflag.eq.0) vzgrid(j)=9.999
C                 if(iflag.eq.1) go to 112
C 120          continue
C            end if
C          end if
C c
C          if(abs(modout).eq.3) then
C            do 210 j=1,nx+1
C               iflag=0
C               if(j.gt.1) then
C                 if(zsmax(j-1).ge.i) iflag=1
C               end if
C               if(j.le.nx) then
C                 if(zsmax(j).ge.i) iflag=1
C               end if
C               if(iflag.eq.0) vzgrid(j)=9.999
C 210        continue
C          end if
C c
C 112      write(31,25) (vzgrid(j),j=1,nx+1)
C 25       format(10f10.3)
C c
C          do 130 j=1,nx+1
C             if(vzgrid(j).ne.9.999)
C      +        write(35,35) xgmt(j),zgmt(j),vzgrid(j)
C 35          format(3f10.3)
C             write(63,26) xgmt(j),-zgmt(j),sample(i,j)
C 26          format(2f10.3,i10)
C 130      continue
C c
C 10    continue
C c
C       do 30 i=nlayer,1,-1
C          if(modi(i).gt.0) then
C            nmodi=i
C            go to 40
C          end if
C 30    continue
C       nmodi=0
C c
C 40    write(31,15) nmodi
C c
C       if(nmodi.gt.0) then
C         do 50 i=1,nmodi
C            igrid(i)=nx+1
C            xgrid(i)=xmmin
C 50      continue
C c
C         write(31,15) (igrid(i),i=1,nmodi)
C         write(31,25) (xgrid(i),i=1,nmodi)
C c
C         do 60 ii=1,nmodi
C            i=modi(ii)
C            il=i
C            ib=1
C            iblk=1
C            do 70 j=1,nx+1
C               x=xmmin+float(j-1)*dx
C               if(x.lt.xmmin) x=xmmin+.001
C               if(x.gt.xmmax) x=xmmax-.001
C 80            if(x.ge.xbnd(il,iblk,1).and.x.le.xbnd(il,iblk,2)) then
C                 vzgrid(j)=s(il,iblk,ib)*x+b(il,iblk,ib)
C                 go to 70
C               else
C                 iblk=iblk+1
C                 go to 80
C               end if
C 70         continue
C c
C            write(31,25) (vzgrid(j),j=1,nx+1)
C c
C 60      continue
C       end if
C c
C       if(ifrbnd.eq.1) then
C c       open(unit=32, file='f.out')
C c
C         if(frz.eq.0.) frz=(zmax-zmin)/1000.
C c
C         do 90 i=1,nfrefl
C c          write(32,15) npfref(i)*2
C c          write(32,25) (xfrefl(i,j),zfrefl(i,j),j=1,npfref(i)),
C c    +                  (xfrefl(i,j),zfrefl(i,j)+frz,j=npfref(i),1,-1)
C 90      continue
C       end if
C c
C       return
C       end
C c
C c     ----------------------------------------------------------------
C c
C       subroutine fd(dxz,xmmin,xmmax,ifd)
C c
C c     output the velocity model on a uniform grid for input to the
C c     finite difference program FD
C c
C       include 'rayinvr.par'
C       include 'rayinvr.com'
C c
C       real vzgrid(pxgrid),xgmt(pxgrid),zgmt(pxgrid)
C c
C       nx=int((xmmax-xmmin)/dxz)
C       nz=int((zmax-zmin)/dxz)
C       xmmaxr=xmmin+float(nx)*dxz
C       zmaxr=zmin+float(nz)*dxz
C c
C       write(0,*) xmmin,xmmaxr,zmin,zmaxr,dxz,nx+1,nz+1
C       if(ifd.ne.2)
C      +  write(35,5) xmmin,xmmaxr,zmin,zmaxr,dxz,nx+1,nz+1
C 5     format(5f10.3,2i10)
C c
C       do 10 i=1,nz+1
C          zmod=zmin+float(i-1)*dxz
C          do 20 j=1,nx+1
C             xmod=xmmin+float(j-1)*dxz
C c
C             call xzpt(xmod,zmod,layer,iblk,iflag)
C c
C             if(iflag.eq.0) then
C               vzgrid(j)=vel(xmod,zmod)
C             else
C               vzgrid(j)=9.999
C             end if
C c
C             xgmt(j)=xmod
C             zgmt(j)=-zmod
C c
C 20       continue
C c
C          if(ifd.ne.2) then
C 112        write(35,25) (vzgrid(j),j=1,nx+1)
C 25         format(10f10.3)
C          else
C            do 30 j=1,nx+1
C               write(35,15) xgmt(j),zgmt(j),vzgrid(j)
C 15            format(3f10.3)
C 30         continue
C          end if
C c
C 10    continue
C c
C       return
C       end
C c
C c     ----------------------------------------------------------------
C c
C       subroutine cells(npt,xmmin,dx,dz)
C c
C c     identify grid cells that have been sampled by ray path
C c
C       include 'rayinvr.par'
C       include 'rayinvr.com'
C c
C       do 10 i=1,npt-1
C          nspts=nint((((xr(i+1)-xr(i))**2+(zr(i+1)-zr(i))**2)**.5)/
C      +         min(dx,dz))+1
C          if(nspts.le.1) nspts=2
C          xinc=(xr(i+1)-xr(i))/float(nspts-1)
C          zinc=(zr(i+1)-zr(i))/float(nspts-1)
C          do 20 j=1,nspts
C             xrp=xr(i)+float(j-1)*xinc
C             zrp=zr(i)+float(j-1)*zinc
C             nx=nint((xrp-xmmin)/dx)+1
C             nz=nint((zrp-zmin)/dz)+1
C             sample(nz,nx)=sample(nz,nx)+1
C 20       continue
C 10    continue
C c
C       return
C       end
