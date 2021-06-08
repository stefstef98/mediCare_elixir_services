import {Injectable} from '@angular/core';
import {Router} from "@angular/router";
import {StorageService} from "../services/storage/storage.service";
import {Observable} from "rxjs";
import {HttpEvent, HttpHandler, HttpHeaders, HttpRequest} from "@angular/common/http";

@Injectable({
  providedIn: 'root'
})
export class InterceptorService {

  constructor(
    private router: Router,
    private storage: StorageService) {
  }

  intercept(request: HttpRequest<any>, next: HttpHandler): Observable<HttpEvent<any>> {
    let headers = new HttpHeaders({
      'Access-Control-Allow-Origin': '*',
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer ' + this.storage.getJwtToken()
    });
    let modifiedReq: HttpRequest<any>;
    modifiedReq = request.clone({headers: headers});
    return next.handle(modifiedReq);
  }
}
