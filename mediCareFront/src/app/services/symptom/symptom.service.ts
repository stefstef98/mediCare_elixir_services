import {Injectable} from '@angular/core';
import {map} from "rxjs/operators";
import {HttpClient} from "@angular/common/http";
import {Symptom} from "../../models/symptom";
import {StorageService} from "../storage/storage.service";

@Injectable({
  providedIn: 'root'
})
export class SymptomService {
  private REST_API_SERVER = "http://localhost:3000/";

  constructor(private httpClient: HttpClient,
              private storage: StorageService) {
  }

  createSymptom(payload: Symptom) {
    return this.httpClient.post(this.REST_API_SERVER + "/symptom", payload, {
      headers: {
        'Content-Type': 'application/json',
        'Access-Control-Allow-Origin': '*',
        'Authentication': 'Bearer ' + this.storage.getJwtToken(),
        'Allow-Origin': '*'
      }
    }).pipe(map(res => {
      return res;
    }))
  }

  getSymtoms() {
    return this.httpClient.get<Symptom[]>(this.REST_API_SERVER + "/symptom", {
      headers: {
        'Accept': 'application/json',
        'Access-Control-Allow-Origin': '*',
        'Authentication': 'Bearer ' + this.storage.getJwtToken(),
        'Allow-Origin': '*'
      }
    }).pipe(map(res => {
      return res;
    }))
  }
}
